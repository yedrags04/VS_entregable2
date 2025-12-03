terraform {
  required_providers {
    kind = {
      source = "tehcyx/kind"
      version = "0.2.0"
    }
    kubernetes = {
      source = "hashicorp/kubernetes"
      version = "2.23.0"
    }
  }
}

provider "kind" {}

resource "kind_cluster" "default" {
  name = "terraform-k8s-cluster"
  
  kind_config {
    kind = "Cluster"
    api_version = "kind.x-k8s.io/v1alpha4"

    node {
      role = "control-plane"
      
      # Mapeo de puertos: Host 8081 -> Contenedor 30081
      extra_port_mappings {
        container_port = 30081
        host_port      = 8081
      }

      # Persistencia de datos
      extra_mounts {
        host_path      = "/tmp/data-matomo/db"
        container_path = "/var/lib/mysql-data"
      }
      extra_mounts {
        host_path      = "/tmp/data-matomo/html"
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

resource "kubernetes_deployment" "mariadb" {
  metadata {
    name = "mariadb"
    labels = { app = "mariadb" }
  }

  spec {
    replicas = 1
    selector { match_labels = { app = "mariadb" } }
    template {
      metadata { labels = { app = "mariadb" } }
      spec {
        container {
          image = "mariadb:10.6" # Versión estable
          name  = "mariadb"

          # Variables de entorno (¡AQUÍ DEFINIMOS USUARIO Y CONTRASEÑA!)
          env {
            name  = "MARIADB_ROOT_PASSWORD"
            value = var.db_password
          }
          env {
            name  = "MARIADB_DATABASE"
            value = var.db_name     # Esto tomará el valor de variables.tf
          }
          env {
            name  = "MARIADB_USER"
            value = var.db_user     # Esto tomará el valor de variables.tf
          }
          env {
            name  = "MARIADB_PASSWORD"
            value = var.db_password # Esto tomará el valor de variables.tf
          }

          # Montar volumen para persistencia
          volume_mount {
            name       = "mariadb-storage"
            mount_path = "/var/lib/mysql"
          }
        }
        # Conexión con la carpeta del Host (definida en el Cluster arriba)
        volume {
          name = "mariadb-storage"
          host_path {
            path = "/var/lib/mysql-data"
            type = "DirectoryOrCreate"
          }
        }
      }
    }
  }
}

resource "kubernetes_service" "mariadb" {
  metadata { name = "mariadb" }
  spec {
    selector = { app = "mariadb" }
    port {
      port        = 3306
      target_port = 3306
    }
  }
}

# --------------------------------------------------------
# 2. APLICACIÓN (Matomo)
# --------------------------------------------------------
resource "kubernetes_deployment" "matomo" {
  metadata {
    name = "matomo"
    labels = { app = "matomo" }
  }
  
  # Esperar a que la base de datos se cree antes de lanzar Matomo
  depends_on = [kubernetes_deployment.mariadb]

  spec {
    replicas = 1
    selector { match_labels = { app = "matomo" } }
    template {
      metadata { labels = { app = "matomo" } }
      spec {
        container {
          # ¡TU IMAGEN PERSONALIZADA!
          image = "ivysudadera/matomo-custom:latest" 
          name  = "matomo"

          # Conectar Matomo con la base de datos
          env {
            name  = "MATOMO_DATABASE_HOST"
            value = "mariadb"
          }
          env {
            name  = "MATOMO_DATABASE_USERNAME"
            value = var.db_user
          }
          env {
            name  = "MATOMO_DATABASE_PASSWORD"
            value = var.db_password
          }
          env {
            name  = "MATOMO_DATABASE_DBNAME"
            value = var.db_name
          }

          # Montar volumen para persistencia
          volume_mount {
            name       = "matomo-storage"
            mount_path = "/var/www/html"
          }
        }
        # Conexión con la carpeta del Host
        volume {
          name = "matomo-storage"
          host_path {
            path = "/var/www/html-data"
            type = "DirectoryOrCreate"
          }
        }
      }
    }
  }
}

resource "kubernetes_service" "matomo" {
  metadata { name = "matomo" }
  spec {
    selector = { app = "matomo" }
    type     = "NodePort"
    port {
      port        = 80
      target_port = 80
      node_port   = 30081 # El puerto que mapeamos en el clúster
    }
  }
}