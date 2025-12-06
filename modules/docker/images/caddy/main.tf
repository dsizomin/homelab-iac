terraform {
  required_providers {
    docker = {
      source  = "kreuzwerker/docker"
      version = "~> 3.0"
    }
  }
}

resource "docker_image" "caddy" {
  name         = var.image_name
  keep_locally = var.keep_locally

  build {
    context    = path.module
    dockerfile = "Dockerfile"
  }
}

