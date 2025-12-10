terraform {
  required_version = ">= 1.6"
  required_providers {
    portainer = {
      source  = "portainer/portainer"
      version = ">= 1.16.1"
    }
    authentik = {
      source  = "goauthentik/authentik"
      version = ">= 2025.10.0"
    }
  }
}

module "auth_provider" {
  source        = "../../authentik/forward_auth_provider"
  name          = "traefik"
  external_host = "https://${var.dns_config.services.traefik}/"
}

resource "portainer_docker_secret" "acme_cloudflare_api_key" {
  endpoint_id     = 1
  data_wo_version = 1
  data_wo         = base64encode(var.acme_cloudflare_api_key)
  name            = "acme_cloudflare_api_key_${replace(timestamp(), ":", ".")}"
  lifecycle {
    ignore_changes        = [name]
    create_before_destroy = true
  }
}

resource "portainer_stack" "this" {
  name            = "traefik"
  deployment_type = "swarm"
  prune           = true
  endpoint_id     = 1

  method          = "file"
  stack_file_path = "./compose.yaml"

  env {
    name  = "ACME_EMAIL"
    value = var.dns_config.email
  }

  env {
    name  = "PROXY_NETWORK_NAME"
    value = var.proxy_network
  }

  env {
    name  = "CF_DNS_API_TOKEN_SECRET"
    value = portainer_docker_secret.acme_cloudflare_api_key.name
  }

  env {
    name  = "TRAEFIK_HOST"
    value = var.dns_config.services.traefik
  }

  env {
    name  = "PROXMOX_HOST"
    value = var.dns_config.services.proxmox
  }

  env {
    name  = "HASS_HOST"
    value = var.dns_config.services.hass
  }
}
