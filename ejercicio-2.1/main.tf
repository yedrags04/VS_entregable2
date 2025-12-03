terraform {
  required_providers {
    kind = {
      source = "tehcyx/kind"
      version = "0.2.0" # Verifica la versión compatible
    }
    kubernetes = {
      source = "hashicorp/kubernetes"
    }
  }
}

provider "kind" {}

resource "kind_cluster" "default" {
  name = "terraform-k8s-cluster"
  kind_config {
    kind      = "Cluster"
    api_version = "kind.x-k8s.io/v1alpha4"

    node {
      role = "control-plane"
      
      # Configuración para acceder al puerto 8081 desde el host [cite: 72]
      extra_port_mappings {
        container_port = 30081 # NodePort que usaremos
        host_port      = 8081  # Puerto en tu máquina
      }

      # PERSISTENCIA REAL: Mapear carpetas locales al nodo de Kind 
      extra_mounts {
        host_path      = "${path.cwd}/data/mariadb"
        container_path = "/var/lib/mysql-data"
      }
      extra_mounts {
        host_path      = "${path.cwd}/data/matomo"
        container_path = "/var/www/html-data"
      }
    }
  }
}

provider "kubernetes" {
  host                   = kind_cluster.default.endpoint
  client_certificate     = kind_cluster.default.client_certificate
  client_key             = kind_cluster.default.client_key
  cluster_ca_certificate = kind_cluster.default.cluster_ca_certificate
}