terraform {
  required_providers {
    docker = {
      source  = "kreuzwerker/docker"
      version = "~> 3.0"
    }
  }
}

resource "docker_image" "portainer_ce" {
  name         = "portainer/portainer-ce:lts"
  keep_locally = false
}

resource "docker_image" "agent" {
  name         = "portainer/agent:lts"
  keep_locally = false
}

resource "docker_network" "agent_network" {
  name     = "agent_network"
  driver   = "overlay"
  internal = true
}

resource "docker_service" "agent" {
  name = "agent"

  task_spec {
    container_spec {
      image = docker_image.agent.name

      mounts {
        target = "/var/run/docker.sock"
        source = "/var/run/docker.sock"
        type   = "bind"
      }
      mounts {
        target = "/var/lib/docker/volumes"
        source = "/var/lib/docker/volumes"
        type   = "bind"
      }

      mounts {
        target    = "/host"
        source    = "/"
        type      = "bind"
        read_only = true
      }
    }
    networks_advanced {
      name = docker_network.agent_network.id
    }
  }

  mode {
    global = true
  }
}

resource "docker_service" "portainer" {
  name = "portainer"

  task_spec {
    container_spec {
      image = docker_image.portainer_ce.name

      args = [
        "-H",
        "tcp://tasks.agent:9001",
        "--tlsskipverify",
      ]

      mounts {
        target = "/data"
        source = "/srv/data/portainer"
        type   = "bind"
      }

    }

    networks_advanced {
      name = docker_network.agent_network.id
    }

    networks_advanced {
      name = var.proxy_network_id
    }
  }

  endpoint_spec {
    ports {
      target_port    = 9443
      published_port = 9443
    }
  }


  labels {
    label = "traefik.enable"
    value = "true"
  }

  labels {
    label = "traefik.http.routers.portainer.rule"
    value = "Host(`${var.dns_config.services.portainer}`)"
  }

  labels {
    label = "traefik.http.services.portainer.loadbalancer.server.port"
    value = "9443"
  }

  labels {
    label = "traefik.http.services.portainer.loadbalancer.server.scheme"
    value = "https"
  }

  mode {
    replicated {
      replicas = 1
    }
  }

  depends_on = [docker_service.agent]
}
