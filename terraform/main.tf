module "debian-apps-vm" {
  source      = "./modules/vms/debian-apps"
  node_name   = var.node_name
  image_store = var.image_store
  username    = var.username
  ssh_pubkey  = var.ssh_pubkey
  opkssh      = var.opkssh
}

module "hass-vm" {
  source      = "./modules/vms/hass"
  node_name   = var.node_name
  image_store = var.image_store
  vm_store    = var.vm_store
}
