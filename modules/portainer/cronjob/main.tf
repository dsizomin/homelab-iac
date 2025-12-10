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
  source          = "../../authentik/forward_auth_provider"
  name            = "healthchecks"
  external_host   = "https://${var.dns_config.services.healthchecks}/"
  skip_path_regex = "/ping/.*"
}

ephemeral "random_password" "secret_key" {
  length           = 64
  special          = true
  override_special = "!#$%&*()-_=+[]{}<>:?"
}

resource "portainer_docker_secret" "secret_key" {
  name            = "healthchecks_secret_key_${replace(timestamp(), ":", ".")}"
  endpoint_id     = 1
  data_wo_version = 1
  data_wo         = base64encode(ephemeral.random_password.secret_key.result)
  lifecycle {
    ignore_changes        = [name]
    create_before_destroy = true
  }
}

resource "portainer_stack" "this" {
  name            = "cronjob"
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
    name  = "SECRET_KEY"
    value = portainer_docker_secret.secret_key.name
  }

  env {
    name  = "HEALTHCHECKS_HOST"
    value = var.dns_config.services.healthchecks
  }
}
