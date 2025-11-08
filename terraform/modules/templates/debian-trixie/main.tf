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
  overwrite_unmanaged = true
}

data "cloudinit_config" "debian-cloud-init-content" {
  gzip          = false
  base64_encode = false

  part {
    content_type = "text/cloud-config"
    content = yamlencode({
      timezone = "Europe/Amsterdam"

      package_update             = true
      package_upgrade            = true
      package_reboot_if_required = true

      hostname = var.vm_flavour

      users = [
        "default",
        {
          name : var.username
          sudo : ["ALL=(ALL) NOPASSWD:ALL"]
          shell : "/usr/bin/zsh"
          groups : "sudo"
          ssh_authorized_keys : [var.ssh_pubkey]
        }
      ]

      groups = ["opksshuser"]

      write_files = [
        {
          path        = "/etc/opk/providers"
          content     = "${var.opkssh.issuer} ${var.opkssh.client_id} 24h\n"
          defer       = true,
          append      = true,
          owner       = "root:opksshuser",
          permissions = "640",
        }
      ]

      packages = [
        "git",
        "zsh",
        "curl",
        "wget",
        "unzip",
        "ca-certificates",
        "qemu-guest-agent",
        "net-tools",
        "tmux",
        "ripgrep",
        "fd-find",
        "fzf",
        "lazygit",
        "gcc",
        "make"
      ]
    })
  }

  part {
    content_type = "text/x-shellscript"
    content = templatefile("${path.module}/resources/user-data.sh", {
      username       = var.username
      opkssh_subject = var.opkssh.subject
      opkssh_issuer  = var.opkssh.issuer
    })
  }
}

resource "proxmox_virtual_environment_file" "debian-cloud-init" {
  node_name    = var.node_name
  datastore_id = var.image_store
  content_type = "snippets"

  source_raw {
    file_name = "${var.vm_flavour}-cloud-init.yaml"
    data      = data.cloudinit_config.debian-cloud-init-content.rendered
  }
}

resource "proxmox_virtual_environment_vm" "debian-template" {
  node_name = var.node_name
  name      = "${var.vm_flavour}-template"
  started   = false
  template  = true
  tags      = ["debian", "terraform", "template"]

  agent { enabled = true }

  serial_device {
    device = "socket"
  }

  scsi_hardware = "virtio-scsi-single"

  disk {
    datastore_id = var.vm_store
    interface    = "scsi0"
    file_id      = proxmox_virtual_environment_download_file.debian-image.id
    size         = var.disk_size
    iothread     = true
    discard      = "on"
  }

  network_device {
    bridge = "vmbr0"
  }

  initialization {
    datastore_id      = var.vm_store
    user_data_file_id = proxmox_virtual_environment_file.debian-cloud-init.id
  }
}
