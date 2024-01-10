variable "cloudflare_api_token" {
  type      = string
  sensitive = true
}

variable "cloudflare_domain_filter" {
  type = string
}

resource "kubernetes_service_account" "external_dns" {
  count = var.test_setup ? 0 : 1
  metadata {
    name = "external-dns"
  }
}

resource "kubernetes_cluster_role" "external_dns" {
  count = var.test_setup ? 0 : 1
  metadata {
    name = "external-dns"
  }

  rule {
    api_groups = [""]
    resources  = ["services", "endpoints", "pods"]
    verbs      = ["get", "watch", "list"]
  }

  rule {
    api_groups = ["extensions", "networking.k8s.io"]
    resources  = ["ingresses"]
    verbs      = ["get", "watch", "list"]
  }

  rule {
    api_groups = [""]
    resources  = ["nodes"]
    verbs      = ["list", "watch"]
  }
}

resource "kubernetes_cluster_role_binding" "external_dns" {
  count = var.test_setup ? 0 : 1
  metadata {
    name = "external-dns"
  }
  role_ref {
    api_group = "rbac.authorization.k8s.io"
    kind      = "ClusterRole"
    name      = "external-dns"
  }
  subject {
    kind      = "ServiceAccount"
    name      = "external-dns"
    namespace = "default"
  }
}

resource "kubernetes_secret" "cloudflare" {
  count = var.test_setup ? 0 : 1
  metadata {
    name = "cloudflare"
  }
  data = {
    api-key = var.cloudflare_api_token
  }
  type = "Opaque"
}

resource "kubernetes_deployment" "external_dns" {
  # TODO: REUSE THIS LINE
  count = var.test_setup ? 0 : 1
  # count = 0
  metadata {
    name = "external-dns"
  }
  spec {
    selector {
      match_labels = {
        app = "external-dns"
      }
    }
    template {
      metadata {
        labels = {
          app = "external-dns"
        }
      }
      spec {
        service_account_name = "external-dns"
        container {
          image = "registry.k8s.io/external-dns/external-dns:v0.14.0"
          name  = "external-dns"
          args = [
            "--source=ingress",
            "--domain-filter=${var.cloudflare_domain_filter}",
            "--provider=cloudflare",
            "--cloudflare-proxied",
            "--cloudflare-dns-records-per-page=5000",
          ]
          env {
            name = "CF_API_TOKEN"
            value_from {
              secret_key_ref {
                name = "cloudflare"
                key  = "api-key"
              }
            }
          }
        }
      }
    }
  }
}
