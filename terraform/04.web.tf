resource "kubernetes_secret" "web_postgres" {
  metadata {
    name = "web-postgres"
  }

  data = {
    password            = var.web_postgres_password
    "postgres-password" = var.web_postgres_password
  }

  type = "kubernetes.io/basic-auth"
}

resource "helm_release" "web_postgres" {
  name       = "web-postgres"
  repository = "https://charts.bitnami.com/bitnami"
  chart      = "postgresql"
  namespace  = "default"
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
