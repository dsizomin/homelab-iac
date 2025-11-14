variable "username" {
  type        = string
  description = "SSH username"
}

variable "portainer_host" {
  type        = string
  description = "Portainer host"
}

variable "portainer_port" {
  type    = string
  default = "9443"
}

variable "portainer_password" {
  type      = string
  sensitive = true
}
