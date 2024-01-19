resource "kubernetes_service_account" "external_dns" {
  depends_on = [kubernetes_namespace.nextit]
  count      = (!var.test_setup && var.k8s_install_external_dns) ? 1 : 0
  metadata {
    name      = "external-dns-nextit"
    namespace = var.k8s_namespace
  }
}

resource "kubernetes_cluster_role" "external_dns" {
  depends_on = [kubernetes_namespace.nextit]
  count      = (!var.test_setup && var.k8s_install_external_dns) ? 1 : 0
  metadata {
    name = "external-dns-nextit"
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
  depends_on = [kubernetes_namespace.nextit, kubernetes_cluster_role.external_dns, kubernetes_service_account.external_dns]
  count      = (!var.test_setup && var.k8s_install_external_dns) ? 1 : 0
  metadata {
    name = "external-dns-nextit"
  }
  role_ref {
    api_group = "rbac.authorization.k8s.io"
    kind      = "ClusterRole"
    name      = "external-dns-nextit"
  }
  subject {
    kind      = "ServiceAccount"
    name      = "external-dns-nextit"
    namespace = var.k8s_namespace
  }
}

resource "kubernetes_secret" "cloudflare" {
  depends_on = [kubernetes_namespace.nextit]
  count      = (!var.test_setup && (var.k8s_install_external_dns || var.k8s_install_cert_manager)) ? 1 : 0
  metadata {
    name      = "cloudflare"
    namespace = var.k8s_namespace
  }
  data = {
    api-key = var.cloudflare_api_token
  }
  type = "Opaque"
}

resource "kubernetes_deployment" "external_dns" {
  depends_on = [kubernetes_namespace.nextit, kubernetes_secret.cloudflare, kubernetes_cluster_role_binding.external_dns]
  count      = (!var.test_setup && var.k8s_install_external_dns) ? 1 : 0
  metadata {
    name      = "external-dns"
    namespace = var.k8s_namespace
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
        service_account_name = "external-dns-nextit"
        container {
          image = "registry.k8s.io/external-dns/external-dns:v0.14.0"
          name  = "external-dns"
          args = [
            "--source=ingress",
            "--domain-filter=${var.cloudflare_domain_filter}",
            "--provider=cloudflare",
            # "--cloudflare-proxied",
            "--cloudflare-dns-records-per-page=5000",
            "--namespace=${var.k8s_namespace}"
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
