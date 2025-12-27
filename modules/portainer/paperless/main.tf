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

ephemeral "random_password" "db_password" {
  length           = 16
  special          = true
  override_special = "!#$%&*()-_=+[]{}<>:?"
}

ephemeral "random_password" "secret_key" {
  length           = 64
  special          = true
  override_special = "!#$%&*()-_=+[]{}<>:?"
}

resource "portainer_docker_secret" "db_password" {
  name            = "paperless_db_password_${replace(timestamp(), ":", ".")}"
  endpoint_id     = 1
  data_wo_version = 1
  data_wo         = base64encode(ephemeral.random_password.db_password.result)
  lifecycle {
    ignore_changes        = [name]
    create_before_destroy = true
  }
}

resource "portainer_docker_secret" "secret_key" {
  name            = "paperless_secret_key_${replace(timestamp(), ":", ".")}"
  endpoint_id     = 1
  data_wo_version = 1
  data_wo         = base64encode(ephemeral.random_password.secret_key.result)
  lifecycle {
    ignore_changes        = [name]
    create_before_destroy = true
  }
}

module "provider" {
  source      = "../../authentik/oidc_provider"
  name        = "paperless"
  client_id   = var.oidc_client_id
  client_type = "public"
  redirect_uris = [
    "https://${var.dns_config.services.paperless}/accounts/oidc/authentik/login/callback/"
  ]
}

resource "portainer_stack" "this" {
  name            = "paperless"
  deployment_type = "swarm"
  prune           = true
  endpoint_id     = 1

  method          = "file"
  stack_file_path = "./compose.yaml"

  env {
    name  = "PROXY_NETWORK"
    value = var.proxy_network
  }

  env {
    name  = "SERVICE_NETWORK"
    value = var.service_network
  }

  env {
    name  = "PAPERLESS_URL"
    value = "https://${var.dns_config.services.paperless}"
  }

  env {
    name  = "PAPERLESS_HOST"
    value = var.dns_config.services.paperless
  }

  env {
    name  = "DB_PASSWORD_SECRET_NAME"
    value = portainer_docker_secret.db_password.name
  }

  env {
    name  = "SECRET_KEY_SECRET_NAME"
    value = portainer_docker_secret.secret_key.name
  }

  env {
    name = "PAPERLESS_SOCIALACCOUNT_PROVIDERS"
    value = jsonencode({
      openid_connect = {
        OAUTH_PKCE_ENABLED = true
        APPS = [{
          provider_id = "authentik"
          name        = "Authentik"
          client_id   = var.oidc_client_id
          settings = {
            server_url = module.provider.oidc_config.provider_info_url
          }
        }]
      }
    })
  }
}

