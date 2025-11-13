module "debian-apps-vm" {
  source      = "./modules/vms/debian-apps"
  node_name   = var.node_name
  image_store = var.image_store
  username    = var.username
  ssh_pubkey  = var.ssh_pubkey
  opkssh      = var.opkssh
}

module "hass-vm" {
  source       = "./modules/vms/hass"
  node_name    = var.node_name
  image_store  = var.image_store
  vm_store     = var.vm_store
  ipv4_address = "${var.ipv4_addresses.hass}/24"
}

module "debian-docker-apps-vm" {
  source       = "./modules/vms/debian-docker-apps"
  node_name    = var.node_name
  image_store  = var.image_store
  username     = var.username
  ssh_pubkey   = var.ssh_pubkey
  opkssh       = var.opkssh
  ipv4_address = "${var.ipv4_addresses.debian-apps}/24"
}

module "portainer-service" {
  source   = "./modules/portainer"
  host     = module.debian-docker-apps-vm.vm_ipv4_address
  username = var.username
}
