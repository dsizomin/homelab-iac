terraform {
  required_version = ">= 1.6"
  required_providers {
    portainer = {
      source  = "portainer/portainer"
      version = ">= 1.16.1"
    }
  }
}

resource "portainer_docker_secret" "ddns_cloudflare_api_key" {
  endpoint_id     = 1
  data_wo_version = 1
  data_wo         = base64encode(var.ddns_cloudflare_api_key)
  name            = "ddns_cloudflare_api_key_${replace(timestamp(), ":", ".")}"
  lifecycle {
    ignore_changes        = [name]
    create_before_destroy = true
  }
}

resource "portainer_stack" "this" {
  name            = "ddns"
  deployment_type = "swarm"
  endpoint_id     = 1

  method          = "file"
  stack_file_path = "./compose.yaml"

  env {
    name  = "DOMAINS"
    value = "home.denyssizomin.com"
  }

  env {
    name  = "SECRET"
    value = portainer_docker_secret.ddns_cloudflare_api_key.name
  }
}
