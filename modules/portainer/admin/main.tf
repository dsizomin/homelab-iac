terraform {
  required_version = ">= 1.6"
  required_providers {
    portainer = {
      source  = "portainer/portainer"
      version = ">= 1.16.1"
    }
  }
}

resource "random_password" "password" {
  length  = 16
  special = false
}

resource "portainer_user_admin" "this" {
  username = var.username
  password = random_password.password.result
}
