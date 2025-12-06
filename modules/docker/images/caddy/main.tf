terraform {
  required_providers {
    docker = {
      source  = "kreuzwerker/docker"
      version = "~> 3.0"
    }
    local = {
      source  = "hashicorp/local"
      version = "~> 2.0"
    }
  }
}

# Render the Caddyfile into the module directory so Docker build can see it
resource "local_file" "caddyfile" {
  filename = "${path.module}/Caddyfile"
  content  = var.caddyfile
}

resource "docker_image" "caddy" {
  name         = var.image_name
  keep_locally = var.keep_locally

  build {
    context    = path.module
    dockerfile = "Dockerfile"
  }

  triggers = {
    caddyfile_sha1 = filesha1(local_file.caddyfile.filename)
  }

  depends_on = [local_file.caddyfile]
}

