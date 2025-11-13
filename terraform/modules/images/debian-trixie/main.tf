terraform {
  required_version = ">= 1.6"
  required_providers {
    proxmox = {
      source  = "bpg/proxmox"
      version = ">= 0.50.0"
    }
  }
}

resource "proxmox_virtual_environment_download_file" "debian-image" {
  node_name           = var.node_name
  datastore_id        = var.image_store
  content_type        = "iso"
  url                 = "https://cloud.debian.org/images/cloud/trixie/latest/debian-13-genericcloud-amd64.qcow2"
  file_name           = "debian-13-genericcloud-amd64.img"
  overwrite           = true
  overwrite_unmanaged = true
}
