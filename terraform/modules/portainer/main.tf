terraform {
  required_version = ">= 1.6"
  required_providers {
    docker = {
      source  = "kreuzwerker/docker"
      version = ">= 3.6.2"
    }
  }
}

resource "docker_network" "agent_network" {
  name       = "agent_network"
  driver     = "overlay"
  attachable = true
}

resource "docker_volume" "portainer_data" {
  name = "portainer_data"
}

resource "docker_image" "agent" {
  name         = "portainer/agent:lts"
  keep_locally = false
}

resource "docker_image" "portainer_ce" {
  name         = "portainer/portainer-ce:lts"
  keep_locally = false
}


resource "docker_service" "agent" {
  name = "agent"

  task_spec {
    container_spec {
      image = docker_image.agent.name

      # Compose: volumes
      mounts {
        # /var/run/docker.sock:/var/run/docker.sock
        target = "/var/run/docker.sock"
        source = "/var/run/docker.sock"
        type   = "bind"
      }
      mounts {
        # /var/lib/docker/volumes:/var/lib/docker/volumes
        target = "/var/lib/docker/volumes"
        source = "/var/lib/docker/volumes"
        type   = "bind"
      }
    }
    networks_advanced {
      name = docker_network.agent_network.id
    }

    placement {
      constraints = ["node.platform.os == linux"]
    }
  }

  endpoint_spec {
    ports {
      target_port    = 9001
      published_port = 9001
      protocol       = "tcp"
      publish_mode   = "ingress"
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
        "--tlsskipverify"
      ]

      mounts {
        target = "/data"
        source = docker_volume.portainer_data.name
        type   = "volume"
      }
    }

    networks_advanced {
      name = docker_network.agent_network.id
    }
    placement {
      constraints = ["node.role == manager"]
    }
  }

  endpoint_spec {
    ports {
      target_port    = 9443
      published_port = 9443
      protocol       = "tcp"
      publish_mode   = "ingress"
    }
    ports {
      target_port    = 9000
      published_port = 9000
      protocol       = "tcp"
      publish_mode   = "ingress"
    }
    ports {
      target_port    = 8000
      published_port = 8000
      protocol       = "tcp"
      publish_mode   = "ingress"
    }
  }

  mode {
    replicated {
      replicas = 1
    }
  }

  depends_on = [docker_service.agent]
}

# resource "docker_service" "portainer-service" {
#   name = "portainer"
#
#   task_spec {
#     container_spec {
#       image = "portainer/portainer-ce:lts"
#       mounts {
#         target = "/data"
#         source = docker_volume.portainer_data.name
#         type   = "volume"
#       }
#       mounts {
#         target = "/var/run/docker.sock"
#         source = "/var/run/docker.sock"
#         type   = "volume"
#       }
#
#     }
#
#     networks_advanced {
#       name = docker_network.proxy_network.name
#     }
#   }
#
#   endpoint_spec {
#
#     ports {
#       target_port    = 9443
#       published_port = 9443
#     }
#     ports {
#       target_port    = 8000
#       published_port = 8000
#     }
#   }
# }

#
#   services:
#   portainer:
#     container_name: portainer
#     image: portainer/portainer-ce:lts
#     restart: always
#     volumes:
#       - /var/run/docker.sock:/var/run/docker.sock
#       - portainer_data:/data
#     ports:
#       - 9443:9443
#       - 8000:8000  # Remove if you do not intend to use Edge Agents
#
# volumes:
#   portainer_data:
#     name: portainer_data
#
# networks:
#   default:
#     name: portainer_network
