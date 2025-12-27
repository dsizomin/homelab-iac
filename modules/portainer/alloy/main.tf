terraform {
  required_version = ">= 1.6"
  required_providers {
    portainer = {
      source  = "portainer/portainer"
      version = ">= 1.16.1"
    }
    grafana = {
      source  = "grafana/grafana"
      version = "4.21.0"
    }
  }
}

resource "grafana_fleet_management_pipeline" "self" {
  name     = "self"
  contents = file("self.alloy")
  matchers = [
    "collector.os=~\".*\"",
  ]
  enabled = true
}

resource "grafana_fleet_management_pipeline" "logging_docker" {
  name     = "logging_docker"
  contents = file("logging_docker.alloy")
  matchers = [
    "platform=~\"^docker.*\"",

  ]
  enabled = true
}

resource "grafana_fleet_management_pipeline" "traefik_prom" {
  name     = "traefik_prom"
  contents = file("traefik_prom.alloy")
  matchers = [
    "platform=~\"^docker.*\"",
  ]
  enabled = true
}

resource "portainer_docker_config" "alloy_config" {
  endpoint_id = 1
  data        = base64encode(file("${path.module}/config.alloy"))
  name        = "config_alloy_${replace(timestamp(), ":", ".")}"
  lifecycle {
    ignore_changes        = [name]
    create_before_destroy = true
  }
}

resource "portainer_docker_secret" "grafana_api_key" {
  endpoint_id     = 1
  data_wo_version = 1
  data_wo         = base64encode(var.grafana_api_key)
  name            = "grafana_api_key_${replace(timestamp(), ":", ".")}"
  lifecycle {
    ignore_changes        = [name]
    create_before_destroy = true
  }
}

resource "portainer_stack" "this" {
  name            = "alloy"
  deployment_type = "swarm"
  endpoint_id     = 1
  prune           = true

  method          = "file"
  stack_file_path = "./compose.yaml"

  env {
    name  = "ALLOY_CONFIG_NAME"
    value = portainer_docker_config.alloy_config.name
  }

  env {
    name  = "GRAFANA_API_KEY_NAME"
    value = portainer_docker_secret.grafana_api_key.name
  }

  env {
    name  = "SERVICE_NETWORK"
    value = var.service_network
  }

  env {
    name  = "PROXY_NETWORK"
    value = var.proxy_network
  }
}
