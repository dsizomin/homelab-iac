terraform {
  required_version = ">= 1.6"
  required_providers {
    sops = {
      source  = "carlpett/sops"
      version = ">= 1.3.0"
    }
    portainer = {
      source  = "portainer/portainer"
      version = ">= 1.16.1"
    }
    docker = {
      source  = "kreuzwerker/docker"
      version = ">= 3.6.2"
    }
  }
}
