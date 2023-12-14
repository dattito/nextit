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
  }
}

variable "authentik_bootstrap_password" {
  type      = string
  sensitive = true
}

variable "authentik_bootstrap_token" {
  type      = string
  sensitive = true
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
  token = var.authentik_bootstrap_token
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
    value = var.authentik_bootstrap_token
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
