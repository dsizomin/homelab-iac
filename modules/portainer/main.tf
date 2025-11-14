resource "docker_network" "agent_network" {
  name     = "agent_network"
  driver   = "overlay"
  internal = true
}

resource "docker_network" "proxy_network" {
  name   = "proxy_network"
  driver = "overlay"
}

resource "docker_image" "agent" {
  name         = "portainer/agent:lts"
  keep_locally = false
}

resource "docker_image" "portainer_ce" {
  name         = "portainer/portainer-ce:lts"
  keep_locally = false
}

resource "docker_secret" "portainer_password" {
  name = "portainer_password"
  data = base64encode(var.portainer_password)
}

locals {
  portainer_password_file_name = "/run/secrets/portainer_password"
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
        "--admin-password-file",
        local.portainer_password_file_name,
        "-H",
        "tcp://tasks.agent:9001",
        "--tlsskipverify",
      ]

      mounts {
        target = "/data"
        source = "/srv/data/portainer"
        type   = "bind"
      }

      secrets {
        secret_id   = docker_secret.portainer_password.id
        secret_name = docker_secret.portainer_password.name
        file_name   = local.portainer_password_file_name
      }
    }

    networks_advanced {
      name = docker_network.agent_network.id
    }

    networks_advanced {
      name = docker_network.proxy_network.id
    }

    placement {
      constraints = ["node.role == manager"]
    }
  }

  endpoint_spec {
    ports {
      target_port    = 9000
      published_port = 9090
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
