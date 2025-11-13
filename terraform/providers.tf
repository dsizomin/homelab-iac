terraform {
  required_version = ">= 1.6"
  required_providers {
    proxmox = {
      source  = "bpg/proxmox"
      version = ">= 0.50.0"
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

provider "docker" {
  host     = "ssh://${var.username}@${var.ipv4_addresses.debian-apps}:22"
  ssh_opts = ["-o", "StrictHostKeyChecking=no", "-o", "UserKnownHostsFile=/dev/null"]
}
