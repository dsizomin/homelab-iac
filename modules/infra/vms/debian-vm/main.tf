terraform {
  required_version = ">= 1.8.0"
  required_providers {
    proxmox = {
      source  = "bpg/proxmox"
      version = "~> 0.65"
    }
    cloudinit = {
      source  = "hashicorp/cloudinit"
      version = "~> 2.3"
    }
  }
}

locals {
  merge_how = [
    {
      name     = "list"
      settings = ["append"]
    },
    {
      name     = "dict"
      settings = ["no_replace", "recurse_list"]
    },
  ]

  core_packages = [
    "git",
    "zsh",
    "curl",
    "wget",
    "unzip",
    "ca-certificates",
    "qemu-guest-agent",
    "net-tools",
    "tmux",
    "gcc",
    "make",
  ]

  users = [
    "default",
    {
      name                = var.username
      sudo                = ["ALL=(ALL) NOPASSWD:ALL"]
      shell               = "/usr/bin/zsh"
      groups              = "sudo"
      ssh_authorized_keys = [var.ssh_pubkey]
    },
  ]

  groups = [
    "opksshuser",
  ]

  write_files = [
    {
      path        = "/etc/opk/providers"
      content     = "${var.opkssh.issuer} ${var.opkssh.client_id} 24h\n"
      defer       = true
      append      = true
      owner       = "root:opksshuser"
      permissions = "640"
    },
  ]

  base_runcmd = [
    "opkssh add ${var.username} ${var.opkssh.subject} ${var.opkssh.issuer}",
  ]
}

resource "proxmox_virtual_environment_download_file" "image" {
  node_name           = var.node_name
  datastore_id        = var.image_store
  content_type        = "iso"
  url                 = "https://cloud.debian.org/images/cloud/trixie/latest/debian-13-genericcloud-amd64.qcow2"
  file_name           = "debian-13-genericcloud-amd64.img"
  overwrite           = true
  overwrite_unmanaged = true
}

data "cloudinit_config" "cloud_init" {
  gzip          = false
  base64_encode = false

  part {
    content_type = "text/cloud-config"
    merge_type   = "list()+dict()+str()"

    content = yamlencode({
      merge_how                  = local.merge_how
      timezone                   = var.timezone
      package_update             = true
      package_upgrade            = true
      package_reboot_if_required = true
      hostname                   = var.name
      users                      = local.users
      groups                     = local.groups
      write_files                = local.write_files
      packages                   = local.core_packages
      runcmd                     = local.base_runcmd
    })
  }

  dynamic "part" {
    for_each = var.cloud_init_parts

    content {
      content_type = part.value.content_type
      content      = part.value.content
      filename     = part.value.filename
      merge_type   = part.value.merge_type
    }
  }

  part {
    content_type = "text/cloud-config"
    merge_type   = "list()+dict()+str()"

    content = yamlencode({
      merge_how = local.merge_how
      runcmd = [
        "systemctl enable qemu-guest-agent",
        "systemctl start qemu-guest-agent",
      ]
    })
  }
}

resource "proxmox_virtual_environment_file" "cloud_init_file" {
  node_name    = var.node_name
  datastore_id = var.image_store
  content_type = "snippets"

  source_raw {
    file_name = "debian-cloud-init-${var.name}.yaml"
    data      = data.cloudinit_config.cloud_init.rendered
  }
}

resource "proxmox_virtual_environment_vm" "this" {
  node_name = var.node_name
  name      = var.name
  started   = var.auto_start
  tags      = var.tags

  cpu {
    cores = var.cpu_cores
    type  = var.cpu_type
  }

  memory {
    dedicated = var.memory_mb
  }

  serial_device {
    device = "socket"
  }

  scsi_hardware = "virtio-scsi-single"

  disk {
    datastore_id = var.vm_store
    interface    = "scsi0"
    file_id      = proxmox_virtual_environment_download_file.image.id
    size         = var.disk_size_gb
    iothread     = true
    discard      = "on"
  }

  initialization {
    datastore_id      = var.vm_store
    user_data_file_id = proxmox_virtual_environment_file.cloud_init_file.id

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


  network_device {
    bridge = "vmbr0"
  }

  agent { enabled = true }
}
