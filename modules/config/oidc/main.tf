locals {
  consumers = toset([
    "opengist",
    "opkssh",
    "paperless",
    "portainer",
    "pulse",
    "proxmox"
  ])
}

resource "random_password" "client_id" {
  length  = 40
  special = false

  for_each = local.consumers
}

