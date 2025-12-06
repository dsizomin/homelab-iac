terraform {
  required_version = ">= 1.6"
  required_providers {
    portainer = {
      source  = "portainer/portainer"
      version = ">= 1.16.1"
    }
    sops = {
      source  = "carlpett/sops"
      version = "1.3.0"
    }
  }
}

resource "portainer_docker_config" "config" {
  endpoint_id = 1
  name        = "autorestic_${replace(timestamp(), ":", ".")}.yaml"
  data        = base64encode(file("${path.module}/autorestic.yaml"))
  lifecycle {
    ignore_changes        = [name]
    create_before_destroy = true
  }
}

data "sops_file" "env" {
  source_file = "${path.module}/autorestic.env"
  input_type  = "dotenv"
}

resource "portainer_docker_secret" "env" {
  name            = "autorestic_${replace(timestamp(), ":", ".")}.env"
  endpoint_id     = 1
  data_wo_version = 1
  data_wo         = base64encode(data.sops_file.env.raw)
  lifecycle {
    ignore_changes        = [name]
    create_before_destroy = true
  }
}

resource "portainer_stack" "this" {
  name            = "autorestic"
  deployment_type = "swarm"
  prune           = true
  endpoint_id     = 1

  method          = "file"
  stack_file_path = "./compose.yaml"

  env {
    name  = "AUTORESTIC_CONFIG_FILE"
    value = portainer_docker_config.config.name
  }

  env {
    name  = "AUTORESTIC_ENV_SECRET"
    value = portainer_docker_secret.env.name
  }

  env {
    name  = "CRONJOB_NETWORK"
    value = var.cronjob_network_id
  }
}
