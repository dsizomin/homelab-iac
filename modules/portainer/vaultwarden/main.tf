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

module "provider" {
  source      = "../../authentik/oidc_provider"
  name        = "valutwarden"
  client_id   = var.oidc_client_id
  client_type = "confidential"
  redirect_uris = [
    "https://${var.dns_config.services.vault}/identity/connect/oidc-signin"
  ]
}

resource "portainer_docker_secret" "oidc_secret_key" {
  name            = "vaultwarden_secrets_${replace(timestamp(), ":", ".")}"
  endpoint_id     = 1
  data_wo_version = 1
  data_wo         = base64encode(module.provider.oidc_secret_key)
  lifecycle {
    ignore_changes        = [name]
    create_before_destroy = true
  }
}

resource "portainer_stack" "this" {
  name            = "vaultwarden"
  deployment_type = "swarm"
  prune           = true
  endpoint_id     = 1

  method          = "file"
  stack_file_path = "./compose.yaml"

  env {
    name  = "DOMAIN"
    value = "https://${var.dns_config.services.vault}"
  }

  env {
    name  = "PROXY_NETWORK"
    value = var.proxy_network
  }

  env {
    name  = "SSO_CLIENT_ID"
    value = var.oidc_client_id
  }

  env {
    name  = "SSO_CLIENT_SECRET_NAME"
    value = portainer_docker_secret.oidc_secret_key.name
  }

  env {
    name  = "SSO_AUTHORITY"
    value = module.provider.oidc_config.issuer_url
  }

}
