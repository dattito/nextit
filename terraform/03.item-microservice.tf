resource "random_password" "item_microservice_postgres" {
  length  = 16
  special = false
}

resource "kubernetes_secret" "item_microservice_postgres" {
  depends_on = [kubernetes_namespace.nextit]
  metadata {
    name      = "item-microservice-postgres"
    namespace = var.k8s_namespace
  }

  data = {
    password            = random_password.item_microservice_postgres.result
    "postgres-password" = random_password.item_microservice_postgres.result
  }
  type = "kubernetes.io/basic-auth"
}

resource "helm_release" "item_microservice_postgres" {
  depends_on = [kubernetes_namespace.nextit]
  name       = "item-microservice-postgres"
  repository = "https://charts.bitnami.com/bitnami"
  chart      = "postgresql"
  namespace  = var.k8s_namespace
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
  depends_on = [helm_release.item_microservice_postgres, kubernetes_namespace.nextit]
  metadata {
    name      = "item-microservice"
    namespace = var.k8s_namespace
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
            name  = "DATABASE_URL"
            value = "postgres://postgres:${random_password.item_microservice_postgres.result}@item-microservice-postgres-postgresql:5432/postgres"
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
    name      = "item-microservice"
    namespace = var.k8s_namespace
  }
  spec {
    selector = {
      app = kubernetes_deployment.item_microservice.spec.0.template.0.metadata.0.labels.app
    }
    port {
      port        = 50051
      target_port = 50051
      node_port   = var.test_setup ? 30051 : 0
    }

    type = var.test_setup ? "NodePort" : "ClusterIP"
  }
}
