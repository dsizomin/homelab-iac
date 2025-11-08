terraform {
  required_providers {
    docker = {
      source  = "kreuzwerker/docker"
      version = "~> 3.0"
    }
  }
}

resource "docker_network" "proxy_network" {
  name     = var.network_name
  driver   = "overlay"
  internal = false
}

