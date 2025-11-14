output "hass_ipv4_address" {
  value = proxmox_virtual_environment_vm.hass_vm.ipv4_addresses[1][0]
}

output "docker_apps_ipv4_address" {
  value = proxmox_virtual_environment_vm.debian_docker_apps_vm.ipv4_addresses[1][0]
}
