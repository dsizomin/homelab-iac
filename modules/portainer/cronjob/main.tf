terraform {
  required_version = ">= 1.6"
  required_providers {
    portainer = {
      source  = "portainer/portainer"
      version = ">= 1.16.1"
    }
  }
}

resource "portainer_docker_network" "cronjob" {
  endpoint_id = 1
  name        = "cronjob_network"
  driver      = "overlay"
  scope       = "swarm"
  attachable  = true
  enable_ipv4 = true

  lifecycle {
    ignore_changes = [options]
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
    name  = "CRONJOB_NETWORK"
    value = portainer_docker_network.cronjob.id
  }
}
