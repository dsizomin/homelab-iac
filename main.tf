module "infra" {
  source = "./modules/infra"

  proxmox_endpoint = var.proxmox_endpoint
  proxmox_token    = var.proxmox_token

  image_store = var.image_store
  vm_store    = var.vm_store

  username   = var.username
  ssh_pubkey = var.ssh_pubkey
  opkssh     = var.opkssh

  ipv4_addresses = var.ipv4_addresses
  ipv4_gateway   = var.ipv4_gateway
}

module "portainer" {
  source = "./modules/portainer"

  username           = var.username
  portainer_host     = module.infra.docker_apps_ipv4_address
  portainer_password = var.portainer_password

}

module "docker_apps" {
  source = "./modules/docker-apps"

  username           = var.username
  portainer_host     = module.infra.docker_apps_ipv4_address
  portainer_password = var.portainer_password

  pulse_env     = var.pulse_env
  ddns_env      = var.ddns_env
  opengist_env  = var.opengist_env
  paperless_env = var.paperless_env

  depends_on = [module.portainer]
}
