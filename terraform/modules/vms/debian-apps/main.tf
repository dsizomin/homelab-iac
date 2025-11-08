terraform {
  required_version = ">= 1.6"
  required_providers {
    proxmox = {
      source  = "bpg/proxmox"
      version = ">= 0.50.0"
    }
  }
}

module "debian-apps-template" {
  source = "../../templates/debian-trixie"

  vm_flavour  = "debian-apps"
  node_name   = var.node_name
  image_store = var.image_store
  username    = var.username
  ssh_pubkey  = var.ssh_pubkey
  opkssh      = var.opkssh
}

resource "proxmox_virtual_environment_vm" "debian-apps-v3" {
  name      = "debian-apps"
  node_name = var.node_name
  started   = true
  tags      = ["debian", "terraform"]

  clone {
    vm_id = module.debian-apps-template.template_vm_id
  }

  cpu {
    cores = 2
  }

  memory { dedicated = 4048 }

  initialization {
    ip_config {
      ipv4 {
        address = "192.168.1.98/24"
        gateway = "192.168.1.1"
      }
    }
  }
}
