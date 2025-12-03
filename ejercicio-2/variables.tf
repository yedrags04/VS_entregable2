variable "db_name" {
  description = "Nombre de la base de datos de WordPress"
  type        = string
}

variable "db_user" {
  description = "Nombre del usuario de la base de datos"
  type        = string
}

variable "db_password" {
  description = "Contraseña del usuario de la base de datos"
  type        = string
  sensitive   = true
}

variable "db_root_password" {
  description = "Contraseña del usuario root de MariaDB"
  type        = string
  sensitive   = true
}

variable "docker_image" {
  description = "Imagen de Docker a desplegar"
  type        = string
  # OPCIÓN A: Si aún no tienes tu GitHub Action funcionando, usa la oficial para probar ya:
  # default     = "matomo:apache" 
  
  # OPCIÓN B: Si ya configuraste GitHub Actions, pon tu usuario real:
  default   = "ivysudadera/matomo-custom:latest"
}