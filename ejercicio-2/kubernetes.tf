# --- MARIA DB ---
resource "kubernetes_deployment" "mariadb" {
  metadata {
    name = "mariadb"
    labels = { app = "mariadb" }
  }
  spec {
    replicas = 1
    selector {
      match_labels = { app = "mariadb" }
    }
    template {
      metadata { labels = { app = "mariadb" } }
      spec {
        container {
          image = "mariadb:10.6" # Imagen oficial 
          name  = "mariadb"
          
          # Variables de entorno desde Terraform 
          env {
            name  = "MARIADB_ROOT_PASSWORD"
            value = var.db_password
          }
          env {
            name  = "MARIADB_DATABASE"
            value = var.db_name
          }
          env {
            name  = "MARIADB_USER"
            value = var.db_user
          }
          env {
            name  = "MARIADB_PASSWORD"
            value = var.db_password
          }
          
          volume_mount {
            name       = "mariadb-storage"
            mount_path = "/var/lib/mysql"
          }
        }
        # Montamos el path del nodo (que a su vez está montado en tu PC)
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

# --- MATOMO ---
resource "kubernetes_deployment" "matomo" {
  depends_on = [kubernetes_deployment.mariadb] # Esperar a la DB es buena práctica

  metadata {
    name = "matomo"
    labels = { app = "matomo" }
  }
  spec {
    replicas = 1
    selector {
      match_labels = { app = "matomo" }
    }
    template {
      metadata { labels = { app = "matomo" } }
      spec {
        container {
          image = var.docker_image # Tu imagen personalizada 
          name  = "matomo"

          # Conexión a DB mediante variables 
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

          volume_mount {
            name       = "matomo-storage"
            mount_path = "/var/www/html"
          }
        }
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
      node_port   = 30081 # Coincide con el extra_port_mapping de main.tf
    }
  }
}