resource "kind_cluster" "docker" {
  count = var.test_setup ? 1 : 0
  name  = "nextit"

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

provider "kubectl" {
  host                   = var.test_setup ? kind_cluster.docker[0].endpoint : ""
  client_certificate     = var.test_setup ? kind_cluster.docker[0].client_certificate : ""
  client_key             = var.test_setup ? kind_cluster.docker[0].client_key : ""
  cluster_ca_certificate = var.test_setup ? kind_cluster.docker[0].cluster_ca_certificate : ""

  config_path    = var.test_setup ? "" : "~/.kube/config"
  config_context = var.test_setup ? "" : var.k8s_context_name
}

provider "kubernetes" {
  host                   = var.test_setup ? kind_cluster.docker[0].endpoint : ""
  client_certificate     = var.test_setup ? kind_cluster.docker[0].client_certificate : ""
  client_key             = var.test_setup ? kind_cluster.docker[0].client_key : ""
  cluster_ca_certificate = var.test_setup ? kind_cluster.docker[0].cluster_ca_certificate : ""

  config_path    = var.test_setup ? "" : "~/.kube/config"
  config_context = var.test_setup ? "" : var.k8s_context_name
}

provider "helm" {
  kubernetes {
    host                   = var.test_setup ? kind_cluster.docker[0].endpoint : ""
    client_certificate     = var.test_setup ? kind_cluster.docker[0].client_certificate : ""
    client_key             = var.test_setup ? kind_cluster.docker[0].client_key : ""
    cluster_ca_certificate = var.test_setup ? kind_cluster.docker[0].cluster_ca_certificate : ""

    config_path    = var.test_setup ? "" : "~/.kube/config"
    config_context = var.test_setup ? "" : var.k8s_context_name
  }
}

resource "kubernetes_namespace" "nextit" {
  count = var.k8s_create_namespace ? 1 : 0
  metadata {
    name = var.k8s_namespace
  }
}
