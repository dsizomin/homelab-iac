resource "proxmox_virtual_environment_download_file" "debian_image" {
  node_name           = var.node_name
  datastore_id        = var.image_store
  content_type        = "iso"
  url                 = "https://cloud.debian.org/images/cloud/trixie/latest/debian-13-genericcloud-amd64.qcow2"
  file_name           = "debian-13-genericcloud-amd64.img"
  overwrite           = true
  overwrite_unmanaged = true
}

locals {
  hostname = "docker-apps"
}

module "debian_docker_apps_cloud_init" {
  source = "./cloud-init"

  hostname    = local.hostname
  username    = var.username
  ssh_pubkey  = var.ssh_pubkey
  vm_store    = var.vm_store
  image_store = var.image_store
  opkssh      = var.opkssh

  cloud_init_parts = [{
    merge_type   = "list()+dict()+str()"
    content_type = "text/cloud-config"
    content = yamlencode({
      merge_how = [
        {
          name     = "list"
          settings = ["append"]
        },
        {
          name     = "dict"
          settings = ["no_replace", "recurse_list"]
        }
      ]

      groups = ["docker"]

      apt = {
        sources = {
          "download-docker-com.list" = {
            source = "deb https://download.docker.com/linux/debian trixie stable",
            key    = file("${path.module}/resources/docker.gpg")
          }
        }
      }

      packages = [
        "docker-ce",
        "docker-ce-cli",
        "containerd.io",
        "docker-buildx-plugin",
        "docker-compose-plugin"
      ]

      runcmd = [
        "usermod -aG docker ${var.username}",
        "systemctl enable docker",
        "systemctl start docker",
        "docker swarm init",
        "bash -c 'mkdir -p /srv/data/{authentik,miniserve,portainer,opengist,paperless,pulse}'",
        "chown -R ${var.username}:${var.username} /srv/data"
      ]
    })
  }]
}

resource "proxmox_virtual_environment_file" "debian_docker_apps_cloud_init_file" {
  node_name    = var.node_name
  datastore_id = var.image_store
  content_type = "snippets"

  source_raw {
    file_name = "${local.hostname}-cloud-init.yaml"
    data      = module.debian_docker_apps_cloud_init.content
  }
}

resource "proxmox_virtual_environment_vm" "debian_docker_apps_vm" {
  node_name = var.node_name
  name      = local.hostname
  started   = true
  tags      = ["debian", "terraform", "docker"]

  agent { enabled = true }

  serial_device {
    device = "socket"
  }

  scsi_hardware = "virtio-scsi-single"

  cpu {
    cores = 2
  }

  memory { dedicated = 4096 }

  initialization {
    datastore_id      = var.vm_store
    user_data_file_id = proxmox_virtual_environment_file.debian_docker_apps_cloud_init_file.id
    ip_config {
      ipv4 {
        address = "${var.ipv4_addresses.docker_apps}/24"
        gateway = var.ipv4_gateway
      }
    }
  }

  disk {
    datastore_id = var.vm_store
    interface    = "scsi0"
    file_id      = proxmox_virtual_environment_download_file.debian_image.id
    size         = 20
    iothread     = true
    discard      = "on"
  }

  network_device {
    bridge = "vmbr0"
  }
}
