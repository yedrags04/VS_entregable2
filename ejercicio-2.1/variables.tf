variable "db_password" {
  description = "Contraseña para la base de datos"
  type        = string
  default     = "mi_password_seguro" # Cámbialo o usa un archivo tfvars
}

variable "db_user" {
  description = "Usuario de la base de datos"
  type        = string
  default     = "matomo_user"
}

variable "db_name" {
  description = "Nombre de la base de datos"
  type        = string
  default     = "matomo_db"
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
          image = "mariadb:latest"
          name  = "mariadb"
          
          env {
            name = "MARIADB_ROOT_PASSWORD"
            value = var.db_password
          }
          env {
            name = "MARIADB_DATABASE"
            value = var.db_name
          }
          env {
            name = "MARIADB_USER"
            value = var.db_user
          }
          env {
            name = "MARIADB_PASSWORD"
            value = var.db_password
          }

          # Montamos el volumen que mapeamos en Kind
          volume_mount {
            name       = "mariadb-storage"
            mount_path = "/var/lib/mysql"
          }
        }
        volume {
          name = "mariadb-storage"
          host_path {
            path = "/var/lib/mysql-data" # Ruta interna en el nodo Kind
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