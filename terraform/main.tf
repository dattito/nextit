terraform {
  required_providers {
    helm = {
      source  = "hashicorp/helm"
      version = "2.12.1"
    }
    kubernetes = {
      source  = "hashicorp/kubernetes"
      version = "2.24.0"
    }
    kind = {
      source  = "tehcyx/kind"
      version = "0.2.1"
    }
    authentik = {
      source  = "goauthentik/authentik"
      version = "2023.10.0"
    }
    random = {
      source  = "hashicorp/random"
      version = "3.6.0"
    }
  }
}

variable "authentik_bootstrap_password" {
  type      = string
  sensitive = true
}

resource "random_password" "authentik_bootstrap_token" {
  length  = 48
  special = true
}

variable "authentik_nextit_clientid" {
  type      = string
  sensitive = true
}

variable "authentik_nextit_clientsecret" {
  type      = string
  sensitive = true
}

variable "authentik_endpoint" {
  type = string
}

resource "kind_cluster" "docker" {
  name = "nextit"

  kind_config {
    kind        = "Cluster"
    api_version = "kind.x-k8s.io/v1alpha4"
    node {
      role = "control-plane"
      extra_port_mappings {
        container_port = 30123
        host_port      = 9000
        listen_address = "127.0.0.1"
      }
      extra_port_mappings {
        container_port = 30051
        host_port      = 50051
        listen_address = "127.0.0.1"
      }
    }
  }
}

provider "kubernetes" {
  host                   = kind_cluster.docker.endpoint
  client_certificate     = kind_cluster.docker.client_certificate
  client_key             = kind_cluster.docker.client_key
  cluster_ca_certificate = kind_cluster.docker.cluster_ca_certificate
}

provider "helm" {
  kubernetes {
    host                   = kind_cluster.docker.endpoint
    client_certificate     = kind_cluster.docker.client_certificate
    client_key             = kind_cluster.docker.client_key
    cluster_ca_certificate = kind_cluster.docker.cluster_ca_certificate
  }
}

provider "authentik" {
  url   = var.authentik_endpoint
  token = random_password.authentik_bootstrap_token.result
}

resource "helm_release" "cert_manager" {
  name       = "cert-manager"
  repository = "https://charts.jetstack.io"
  chart      = "cert-manager"
  namespace  = "default"
  version    = "v1.13.3"
  set {
    name  = "installCRDs"
    value = "true"
  }
}

resource "helm_release" "authentik" {
  name       = "authentik"
  repository = "https://charts.goauthentik.io"
  chart      = "authentik"
  namespace  = "default"
  version    = "2023.10.4"

  values = [
    file("authentik-helm-values.yaml"),
  ]

  set {
    name  = "env.AUTHENTIK_BOOTSTRAP_PASSWORD"
    value = var.authentik_bootstrap_password
  }

  set {
    name  = "env.AUTHENTIK_BOOTSTRAP_TOKEN"
    value = random_password.authentik_bootstrap_token.result
  }
}

# ----------------------------------------
# AUTHENTIK
# ----------------------------------------

data "authentik_flow" "default-authorization-flow" {
  depends_on = [helm_release.authentik]
  slug       = "default-provider-authorization-explicit-consent"
}

data "authentik_scope_mapping" "oauth" {
  depends_on = [helm_release.authentik]
  managed_list = [
    "goauthentik.io/providers/oauth2/scope-email",
    "goauthentik.io/providers/oauth2/scope-profile",
    "goauthentik.io/providers/oauth2/scope-openid"
  ]
}

data "authentik_certificate_key_pair" "default" {
  depends_on = [helm_release.authentik]
  name       = "authentik Self-signed Certificate"
}

resource "authentik_provider_oauth2" "nextjs_web" {
  name               = "nextit"
  client_id          = var.authentik_nextit_clientid
  client_secret      = var.authentik_nextit_clientsecret
  authorization_flow = data.authentik_flow.default-authorization-flow.id
  property_mappings  = data.authentik_scope_mapping.oauth.ids
  signing_key        = data.authentik_certificate_key_pair.default.id
}

resource "authentik_application" "nextjs-web" {
  name              = "Next-IT Dashboard"
  slug              = "nextit"
  protocol_provider = authentik_provider_oauth2.nextjs_web.id
}

# ----------------------------------------
# ITEM MICROSERVICE
# ----------------------------------------

resource "random_password" "item_microservice_postgres" {
  length  = 32
  special = false
}

resource "kubernetes_secret" "item_microservice_postgres" {
  metadata {
    name = "item-microservice-postgres"
  }

  data = {
    password            = random_password.item_microservice_postgres.result
    "postgres-password" = random_password.item_microservice_postgres.result
  }

  type = "kubernetes.io/basic-auth"
}

resource "helm_release" "item_microservice_postgres" {
  name       = "item-microservice-postgres"
  repository = "https://charts.bitnami.com/bitnami"
  chart      = "postgresql"
  namespace  = "default"
  version    = "13.2.24"

  set {
    name  = "auth.username"
    value = "item"
  }

  set {
    name  = "auth.existingSecret"
    value = kubernetes_secret.item_microservice_postgres.metadata[0].name
  }

  set {
    name  = "auth.database"
    value = "item"
  }
}

resource "kubernetes_deployment" "item_microservice" {
  depends_on = [helm_release.item_microservice_postgres]
  metadata {
    name = "item-microservice"
  }

  spec {
    replicas = 1
    selector {
      match_labels = {
        app = "item-microservice"
      }
    }
    template {
      metadata {
        labels = {
          app = "item-microservice"
        }
      }
      spec {
        container {
          image = "ghcr.io/dattito/nextit/item-microservice:0.2"
          name  = "item-microservice"

          env {
            name = "DATABASE_URL"
            value = "postgres://postgres:${random_password.item_microservice_postgres.result
            }@item-microservice-postgres-postgresql:5432/postgres"
          }

          port {
            container_port = "50051"
          }
        }
      }
    }
  }
}

resource "kubernetes_service" "item_microservice" {
  metadata {
    name = "item-microservice"
  }
  spec {
    selector = {
      app = kubernetes_deployment.item_microservice.spec.0.template.0.metadata.0.labels.app
    }
    port {
      port        = 50051
      target_port = 50051
      node_port   = 30051
    }

    type = "NodePort"
  }
}
