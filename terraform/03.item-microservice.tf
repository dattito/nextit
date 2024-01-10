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
          image = "ghcr.io/dattito/nextit/item-microservice:0.3-${var.platform}"
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

    type = var.test_setup ? "NodePort" : "ClusterIP"
  }
}
