terraform {
  required_version = ">= 1.6"
  required_providers {
    portainer = {
      source  = "portainer/portainer"
      version = ">= 1.16.1"
    }
  }
}

resource "portainer_docker_secret" "acme_cloudflare_api_key" {
  endpoint_id     = 1
  data_wo_version = 2
  data_wo         = base64encode(var.acme_cloudflare_api_key)
  name            = "acme_cloudflare_api_key_${replace(timestamp(), ":", ".")}"
  lifecycle {
    ignore_changes        = [name]
    create_before_destroy = true
  }
}

resource "portainer_docker_config" "caddyfile" {
  endpoint_id = 1
  name        = "Caddyfile_${replace(timestamp(), ":", ".")}"
  data = base64encode(
    templatefile("${path.module}/Caddyfile.tftpl", {
      email          = var.dns_config.email
      auth_fqdn      = var.dns_config.services.auth
      paperless_fqdn = var.dns_config.services.paperless
      gist_fqdn      = var.dns_config.services.gist
      cdn_fqdn       = var.dns_config.services.cdn
      pulse_fqdn     = var.dns_config.services.pulse
      proxmox_fqdn   = var.dns_config.services.proxmox
      hass_fqdn      = var.dns_config.services.hass
      portainer_fqdn = var.dns_config.services.portainer
      vault_fqdn     = var.dns_config.services.vault
    }),
  )
  lifecycle {
    ignore_changes        = [name]
    create_before_destroy = true
  }
}

resource "portainer_stack" "this" {
  name            = "caddy"
  deployment_type = "swarm"
  endpoint_id     = 1

  method          = "file"
  stack_file_path = "./compose.yaml"

  env {
    name  = "IMAGE"
    value = var.image_id
  }

  env {
    name  = "PROXY_NETWORK"
    value = var.proxy_network
  }

  env {
    name  = "CADDYFILE"
    value = portainer_docker_config.caddyfile.name
  }

  env {
    name  = "SECRET"
    value = portainer_docker_secret.acme_cloudflare_api_key.name
  }
}
