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
      extra_port_mappings {
        container_port = 30543
        host_port      = 5433
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

# resource "helm_release" "cert_manager" {
#   name       = "cert-manager"
#   repository = "https://charts.jetstack.io"
#   chart      = "cert-manager"
#   namespace  = "default"
#   version    = "v1.13.3"
#   set {
#     name  = "installCRDs"
#     value = "true"
#   }
# }
