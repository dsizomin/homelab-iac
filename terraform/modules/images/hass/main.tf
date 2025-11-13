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
  overwrite               = true
  overwrite_unmanaged     = true
}
