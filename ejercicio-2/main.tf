# 1. Definición del proveedor Docker
terraform {
  required_providers {
    docker = {
      source  = "kreuzwerker/docker"
      version = "~> 3.0"
    }
  }
}

provider "docker" {}

# 2. Red Docker
resource "docker_network" "red_wp" {
  name = "red_wordpress_tf"
}

# 3. Volúmenes Persistentes
resource "docker_volume" "db_data" {
  name = "mariadb_data_tf"
}

resource "docker_volume" "wordpress_data" {
  name = "wordpress_data_tf"
}

# 4. Contenedor MariaDB
resource "docker_container" "mariadb" {
  name  = "servidor_mariadb_tf"
  image = "mariadb:latest"
  restart = "always"

  # Conexión a la red
  networks_advanced {
    name = docker_network.red_wp.name
    aliases = ["mariadb"] # Alias para que WordPress lo encuentre
  }

  # Persistencia de datos
  volumes {
    volume_name    = docker_volume.db_data.name
    container_path = "/var/lib/mysql"
  }

  # Variables de entorno para configuración (Ej: MYSQL_DATABASE, MYSQL_USER, etc.)
  env = [
    "MARIADB_ROOT_PASSWORD=${var.db_root_password}",
    "MARIADB_DATABASE=${var.db_name}",
    "MARIADB_USER=${var.db_user}",
    "MARIADB_PASSWORD=${var.db_password}"
  ]
}

# 5. Contenedor WordPress
resource "docker_container" "wordpress" {
  name  = "servidor_wordpress_tf"
  image = "wordpress:latest"
  restart = "always"

  # Puerto de acceso: 8080 en el host, 80 en el contenedor
  ports {
    internal = 80
    external = 8080
  }

  # Conexión a la red
  networks_advanced {
    name = docker_network.red_wp.name
  }

  # Persistencia de datos
  volumes {
    volume_name    = docker_volume.wordpress_data.name
    container_path = "/var/www/html" 
  }

  # Dependencia para asegurar que MariaDB esté listo
  depends_on = [docker_container.mariadb]

  # Variables de entorno para configuración de WordPress (conectarse a la DB)
  env = [
    "WORDPRESS_DB_HOST=mariadb:3306", # Usamos el alias de red de MariaDB
    "WORDPRESS_DB_USER=${var.db_user}",
    "WORDPRESS_DB_PASSWORD=${var.db_password}",
    "WORDPRESS_DB_NAME=${var.db_name}"
  ]
}

# 6. Salida para verificar el acceso
output "wordpress_url" {
  value = "http://localhost:8080"
}