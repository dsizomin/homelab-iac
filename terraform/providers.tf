terraform {
  required_version = ">= 1.6"
  required_providers {
    proxmox = {
      source  = "bpg/proxmox"
      version = ">= 0.50.0"
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

