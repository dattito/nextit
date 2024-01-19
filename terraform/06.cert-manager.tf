resource "helm_release" "cert_manager" {
  depends_on = [kubernetes_namespace.nextit]
  count      = (!var.test_setup && var.k8s_install_cert_manager) ? 1 : 0
  name       = "cert-manager"
  repository = "https://charts.jetstack.io"
  chart      = "cert-manager"
  namespace  = var.k8s_namespace
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

resource "kubectl_manifest" "cluster_issuer" {
  depends_on = [helm_release.cert_manager, kubernetes_namespace.nextit]
  count      = (!var.test_setup && var.k8s_install_cert_manager_crs) ? 1 : 0

  yaml_body = <<YAML
apiVersion: cert-manager.io/v1
kind: Issuer
metadata:
  name: cloudflare-issuer
  namespace: ${var.k8s_namespace}
spec:
  acme:
    server: "https://acme-v02.api.letsencrypt.org/directory"
    email: ${var.acme_email}
    privateKeySecretRef:
      name: cloudflare-issuer-account-key
    solvers:
      - dns01:
          cloudflare:
            apiTokenSecretRef:
              name: cloudflare
              key: api-key
YAML
}

resource "kubectl_manifest" "tls-certificate" {
  depends_on = [kubectl_manifest.cluster_issuer, kubernetes_namespace.nextit]
  count      = (!var.test_setup && var.k8s_install_cert_manager_crs) ? 1 : 0

  yaml_body = <<YAML
apiVersion: cert-manager.io/v1
kind: Certificate
metadata:
  name: nextitcloud-certificate
  namespace: ${var.k8s_namespace}
spec:
  secretName: nextitcloud-tls
  dnsNames:
    - "*.nextit.cloud"
    - nextit.cloud
  issuerRef:
    kind: Issuer
    name: cloudflare-issuer
YAML
}
