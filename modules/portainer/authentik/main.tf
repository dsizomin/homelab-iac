terraform {
  required_version = ">= 1.6"
  required_providers {
    portainer = {
      source  = "portainer/portainer"
      version = ">= 1.16.1"
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
  endpoint_id     = 1
  data_wo_version = 1
  data_wo         = base64encode(ephemeral.random_password.db_password.result)
  name            = "authentik_db_password_${replace(timestamp(), ":", ".")}"
  lifecycle {
    ignore_changes        = [name]
    create_before_destroy = true
  }
}

resource "portainer_docker_secret" "secret_key" {
  endpoint_id     = 1
  data_wo_version = 2
  data_wo         = base64encode(ephemeral.random_password.secret_key.result)
  name            = "authentik_secret_key_${replace(timestamp(), ":", ".")}"
  lifecycle {
    ignore_changes        = [name]
    create_before_destroy = true
  }
}

resource "portainer_stack" "this" {
  name            = "authentik"
  deployment_type = "swarm"
  endpoint_id     = 1
  prune           = true

  method          = "file"
  stack_file_path = "./compose.yaml"

  env {
    name  = "DB_PASSWORD_SECRET_NAME"
    value = portainer_docker_secret.db_password.name
  }
  env {
    name  = "SECRET_KEY_SECRET_NAME"
    value = portainer_docker_secret.secret_key.name
  }
  env {
    name  = "PROXY_NETWORK"
    value = var.proxy_network
  }
}
