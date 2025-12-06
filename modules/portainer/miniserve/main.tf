terraform {
  required_version = ">= 1.6"
  required_providers {
    portainer = {
      source  = "portainer/portainer"
      version = ">= 1.16.1"
    }
  }
}

resource "portainer_stack" "this" {
  name            = "miniserve"
  deployment_type = "swarm"
  prune           = true
  endpoint_id     = 1

  method          = "file"
  stack_file_path = "./compose.yaml"
}
