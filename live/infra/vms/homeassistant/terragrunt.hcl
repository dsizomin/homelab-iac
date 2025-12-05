include "root" {
  path = find_in_parent_folders("root.hcl")
}

include "proxmox" {
  path = find_in_parent_folders("providers.hcl")
}

terraform {
  source = "../../../../modules/infra/vms/hass-vm"
}

dependency "dns_config" {
  config_path = "../../../config/dns"
}

inputs = {
  name        = "homeassistant"
  node_name   = "pve"
  vm_store    = "local-lvm"
  image_store = "local"

  cpu_cores    = 2
  memory_mb    = 4096
  disk_size_gb = 32


  ipv4_address = "192.168.1.44/24"
  ipv4_gateway = "192.168.1.1"
  dns_servers  = [
    dependency.dns_config.outputs.dns_servers.primary,
    dependency.dns_config.outputs.dns_servers.secondary,
  ]


  tags = ["terraform", "homeassistant", "vm"]
}

