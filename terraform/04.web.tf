resource "random_password" "web_postgres" {
  length  = 16
  special = false
}

resource "kubernetes_secret" "web_postgres" {
  depends_on = [kubernetes_namespace.nextit]
  metadata {
    name      = "web-postgres"
    namespace = var.k8s_namespace
  }

  data = {
    password            = var.test_setup ? "postgres" : random_password.web_postgres.result
    "postgres-password" = var.test_setup ? "postgres" : random_password.web_postgres.result
  }
  type = "kubernetes.io/basic-auth"
}

resource "helm_release" "web_postgres" {
  depends_on = [kubernetes_namespace.nextit]
  name       = "web-postgres"
  repository = "https://charts.bitnami.com/bitnami"
  chart      = "postgresql"
  namespace  = var.k8s_namespace
  version    = "13.2.24"

  set {
    name  = "auth.username"
    value = "web"
  }

  set {
    name  = "auth.existingSecret"
    value = kubernetes_secret.web_postgres.metadata[0].name
  }

  set {
    name  = "auth.database"
    value = "web"
  }

  set {
    name  = "primary.service.type"
    value = var.test_setup ? "NodePort" : "ClusterIP"
  }

  set {
    name  = "primary.service.nodePorts.postgresql"
    value = "30543"
  }
}

resource "kubernetes_secret" "web" {
  depends_on = [kubernetes_namespace.nextit]
  count      = var.test_setup ? 0 : 1

  metadata {
    name      = "web"
    namespace = var.k8s_namespace
  }

  data = {
    "NEXTAUTH_SECRET" : var.nextauth_secret,
    "AUTHENTIK_ISSUER" : "${var.authentik_endpoint_protocol}://${var.authentik_endpoint_domain}/application/o/nextit",
    "DATABASE_URL" : "postgres://postgres:${random_password.web_postgres.result}@web-postgres-postgresql:5432/postgres",
    "AUTHENTIK_LOGOUT_URL" : "${var.authentik_endpoint_protocol}://${var.authentik_endpoint_domain}/flows/-/default/invalidation/",
    "AUTHENTIK_CLIENTID" : var.authentik_nextit_clientid,
    "AUTHENTIK_CLIENTSECRET" : var.authentik_nextit_clientsecret,
    "ITEM_SERVICE_HOST" : "item-microservice:50051",
  }
}

resource "kubernetes_deployment" "web" {
  count      = var.test_setup ? 0 : 1
  depends_on = [helm_release.web_postgres, kubernetes_namespace.nextit]
  metadata {
    name      = "web"
    namespace = var.k8s_namespace
  }

  spec {
    replicas = 1
    selector {
      match_labels = {
        app = "web"
      }
    }
    template {
      metadata {
        labels = {
          app = "web"
        }
      }
      spec {
        container {
          image = "ghcr.io/dattito/nextit/web:0.4-${var.platform}"
          name  = "web"

          env_from {
            secret_ref {
              name = "web"
            }
          }

          port {
            container_port = "3000"
          }
        }
      }
    }
  }
}

resource "kubernetes_service" "web" {
  count = var.test_setup ? 0 : 1
  metadata {
    name      = "web"
    namespace = var.k8s_namespace
  }
  spec {
    selector = {
      app = kubernetes_deployment.web.0.spec.0.template.0.metadata.0.labels.app
    }
    port {
      port        = 3000
      target_port = 3000
      node_port   = var.test_setup ? 30052 : 0
    }

    type = var.test_setup ? "NodePort" : "ClusterIP"
  }
}

resource "kubernetes_ingress_v1" "web" {
  depends_on = [kubernetes_namespace.nextit]
  count      = var.test_setup ? 0 : 1

  metadata {
    name      = "web"
    namespace = var.k8s_namespace
  }

  spec {
    rule {
      host = var.traefik_web_domain
      http {
        path {
          path = "/"
          backend {
            service {
              name = "web"
              port {
                number = 3000
              }
            }
          }
        }
      }
    }
    tls {
      hosts       = [var.traefik_web_domain]
      secret_name = "nextitcloud-tls"
    }
  }
}
