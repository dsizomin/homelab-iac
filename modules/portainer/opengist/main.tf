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
  name        = "opengist"
  client_id   = var.oidc_client_id
  client_type = "confidential"
  redirect_uris = [
    "https://${var.dns_config.services.gist}/oauth/openid-connect/callback"
  ]
}

resource "portainer_docker_secret" "opengist_secret" {
  name            = "opengist_secrets_${replace(timestamp(), ":", ".")}"
  endpoint_id     = 1
  data_wo_version = 1
  data_wo         = base64encode("OG_OIDC_SECRET=${module.provider.oidc_secret_key}")
  lifecycle {
    ignore_changes        = [name]
    create_before_destroy = true
  }
}

resource "authentik_group" "admin_group" {
  name = "opengist_admins"
}

resource "portainer_stack" "this" {
  name            = "opengist"
  deployment_type = "swarm"
  endpoint_id     = 1
  prune           = true

  method          = "file"
  stack_file_path = "./compose.yaml"

  env {
    name  = "OG_OIDC_PROVIDER_NAME"
    value = "authentik"
  }

  env {
    name  = "OG_OIDC_CLIENT_KEY"
    value = var.oidc_client_id
  }

  env {
    name  = "OG_OIDC_DISCOVERY_URL"
    value = module.provider.oidc_config.provider_info_url
  }

  env {
    name  = "SECRET_NAME"
    value = portainer_docker_secret.opengist_secret.name
  }

  env {
    name  = "OG_OIDC_GROUP_CLAIM_NAME"
    value = "groups"
  }

  env {
    name  = "OG_OIDC_ADMIN_GROUP"
    value = authentik_group.admin_group.name
  }

  env {
    name  = "PROXY_NETWORK"
    value = var.proxy_network
  }

  env {
    name  = "OPENGIST_HOST"
    value = var.dns_config.services.gist
  }
}

