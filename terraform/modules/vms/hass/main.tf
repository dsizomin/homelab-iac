terraform {
  required_version = ">= 1.6"
  required_providers {
    proxmox = {
      source  = "bpg/proxmox"
      version = ">= 0.50.0"
    }
  }
}

resource "proxmox_virtual_environment_download_file" "hass-image" {
  node_name               = var.node_name
  datastore_id            = var.image_store
  content_type            = "iso"
  url                     = "https://github.com/home-assistant/operating-system/releases/download/16.3/haos_ova-16.3.qcow2.xz"
  file_name               = "haos_ova-16.3.qcow2.xz.img"
  decompression_algorithm = "zst"
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
    file_id      = proxmox_virtual_environment_download_file.hass-image.id
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
        address = "192.168.1.44/24"
        gateway = "192.168.1.1"
      }
    }
  }
}

