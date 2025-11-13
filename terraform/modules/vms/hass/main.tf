terraform {
  required_version = ">= 1.6"
  required_providers {
    proxmox = {
      source  = "bpg/proxmox"
      version = ">= 0.50.0"
    }
  }
}

module "hass-image" {
  source = "../../images/hass"

  node_name   = var.node_name
  image_store = var.image_store
}

resource "proxmox_virtual_environment_vm" "hass" {
  name      = "hass"
  node_name = var.node_name
  started   = true
  tags      = ["hass", "terraform"]

  bios = "ovmf"

  machine = "q35"

  efi_disk {
    datastore_id      = var.vm_store
    type              = "4m"
    pre_enrolled_keys = false
  }

  cpu {
    cores = 2
  }

  memory { dedicated = 6144 }

  agent { enabled = true }

  serial_device {
    device = "socket"
  }

  scsi_hardware = "virtio-scsi-pci"

  disk {
    datastore_id = var.vm_store
    interface    = "scsi0"
    file_id      = module.hass-image.id
    size         = 32
    discard      = "on"
    ssd          = true
  }

  boot_order = ["scsi0"]

  network_device {
    bridge = "vmbr0"
  }

  initialization {
    ip_config {
      ipv4 {
        address = var.ipv4_address
        gateway = "192.168.1.1"
      }
    }
  }
}

