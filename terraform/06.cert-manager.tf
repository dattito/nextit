resource "helm_release" "cert_manager" {
  count      = var.test_setup ? 0 : 1
  name       = "cert-manager"
  repository = "https://charts.jetstack.io"
  chart      = "cert-manager"
  namespace  = "default"
  version    = "v1.13.3"

  set {
    name  = "installCRDs"
    value = "true"
  }

  set {
    name  = "extraArgs"
    value = "{--dns01-recursive-nameservers-only,--dns01-recursive-nameservers=8.8.8.8:53,1.1.1.1:53}"
  }
}

# resource "kubectl_manifest" "cluster_issuer" {
#   depends_on = [helm_release.cert_manager]
#   count      = var.test_setup ? 0 : 1
#
#   yaml_body = <<YAML
# apiVersion: cert-manager.io/v1
# kind: ClusterIssuer
# metadata:
#   name: cloudflare-issuer
# spec:
#   acme:
#     server: "https://acme-v02.api.letsencrypt.org/directory"
#     email: ${var.acme_email}
#     privateKeySecretRef:
#       name: cloudflare-issuer-account-key
#     solvers:
#       - dns01:
#           cloudflare:
#             apiTokenSecretRef:
#               name: cloudflare
#               key: api-key
# YAML
# }
#
# resource "kubectl_manifest" "tls-certificate" {
#   depends_on = [helm_release.cert_manager]
#   count      = var.test_setup ? 0 : 1
#
#   yaml_body = <<YAML
# apiVersion: cert-manager.io/v1
# kind: Certificate
# metadata:
#   name: nextitcloud-certificate
#   namespace: default
# spec:
#   secretName: nextitcloud-tls
#   dnsNames:
#     - "*.nextit.cloud"
#     - nextit.cloud
#   issuerRef:
#     kind: ClusterIssuer
#     name: cloudflare-issuer
# YAML
# }
