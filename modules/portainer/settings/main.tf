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

locals {
  portainer_url = "https://${var.portainer_hostname}"
}

module "provider" {
  source      = "../../authentik/oidc_provider"
  name        = "portainer"
  client_id   = var.oidc_client_id
  client_type = "public"
  redirect_uris = [
    local.portainer_url
  ]
}


resource "portainer_settings" "portainer_settings" {
  authentication_method = 3

  oauth_settings {
    client_id               = var.oidc_client_id
    client_secret           = ""
    redirect_uri            = local.portainer_url
    access_token_uri        = module.provider.oidc_config.token_url
    authorization_uri       = module.provider.oidc_config.authorize_url
    resource_uri            = module.provider.oidc_config.user_info_url
    logout_uri              = module.provider.oidc_config.logout_url
    oauth_auto_create_users = true
    sso                     = true
    user_identifier         = "preferred_username"
    scopes                  = "email openid profile"
  }
}
