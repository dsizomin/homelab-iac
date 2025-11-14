terraform {
  required_version = ">= 1.6"
  required_providers {
    proxmox = {
      source  = "bpg/proxmox"
      version = ">= 0.50.0"
    }
    sops = {
      source  = "carlpett/sops"
      version = ">= 1.3.0"
    }
    portainer = {
      source  = "portainer/portainer"
      version = ">= 1.16.1"
    }
    docker = {
      source  = "kreuzwerker/docker"
      version = ">= 3.6.2"
    }
  }
}

provider "proxmox" {
  endpoint  = var.proxmox_endpoint # e.g., "https://pve1:8006/api2/json"
  api_token = var.proxmox_token    # "user@pam!tokenname:secret"

  ssh {
    username    = "root"
    agent       = true
    private_key = file("~/.ssh/homelab")
  }
}

locals {
  docker_apps_ipv4_address = var.ipv4_addresses.docker_apps
}

provider "docker" {
  host     = "ssh://${var.username}@${local.docker_apps_ipv4_address}:22"
  ssh_opts = ["-o", "StrictHostKeyChecking=no", "-o", "UserKnownHostsFile=/dev/null"]
}

provider "portainer" {
  api_user        = "admin"
  api_password    = var.portainer_password
  endpoint        = "https://${local.docker_apps_ipv4_address}:9443"
  skip_ssl_verify = true
}
