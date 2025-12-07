terraform {
  required_version = ">= 1.8.0"

  required_providers {
    proxmox = {
      source  = "bpg/proxmox"
      version = "~> 0.65"
    }
  }
}

resource "proxmox_virtual_environment_download_file" "hass_image" {
  node_name               = var.node_name
  datastore_id            = var.image_store
  content_type            = "iso"
  url                     = "https://github.com/home-assistant/operating-system/releases/download/16.3/haos_ova-16.3.qcow2.xz"
  file_name               = "haos_ova-16.3.qcow2.xz.img"
  decompression_algorithm = "zst"
  overwrite               = true
  overwrite_unmanaged     = true
}

resource "proxmox_virtual_environment_vm" "this" {
  name      = var.name
  node_name = var.node_name
  tags      = var.tags

  bios = "ovmf"

  machine = "q35"

  cpu {
    cores = var.cpu_cores
    type  = var.cpu_type
  }

  memory {
    dedicated = var.memory_mb
    floating  = var.memory_mb
  }

  efi_disk {
    datastore_id      = var.vm_store
    type              = "4m"
    pre_enrolled_keys = false
  }

  serial_device {
    device = "socket"
  }

  scsi_hardware = "virtio-scsi-single"

  disk {
    datastore_id = var.vm_store
    interface    = "scsi0"
    file_id      = proxmox_virtual_environment_download_file.hass_image.id
    size         = var.disk_size_gb
    discard      = "on"
    ssd          = true
    iothread     = true
  }

  boot_order = ["scsi0"]

  network_device {
    bridge = "vmbr0"
  }

  initialization {
    ip_config {
      ipv4 {
        address = var.ipv4_address
        gateway = var.ipv4_gateway
      }
    }

    dns {
      servers = var.dns_servers
    }
  }

  agent {
    enabled = true
  }

  started = var.auto_start
}
