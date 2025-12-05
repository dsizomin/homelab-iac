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
  name        = "pulse"
  client_id   = var.oidc_client_id
  client_type = "public"
  redirect_uris = [
    "https://${var.dns_config.services.pulse}/api/oidc/callback"
  ]
}

resource "portainer_stack" "this" {
  name            = "pulse"
  deployment_type = "swarm"
  endpoint_id     = 1

  method          = "file"
  stack_file_path = "./compose.yaml"

  env {
    name  = "PULSE_PUBLIC_URL"
    value = "https://${var.dns_config.services.pulse}"
  }
  env {
    name  = "OIDC_CLIENT_ID"
    value = var.oidc_client_id
  }
  env {
    name  = "OIDC_ISSUER_URL"
    value = module.provider.oidc_config.issuer_url
  }

  env {
    name  = "PROXY_NETWORK"
    value = var.proxy_network
  }

}
