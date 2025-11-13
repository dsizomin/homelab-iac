output "vm_id" {
  value       = proxmox_virtual_environment_vm.debian-docker-apps.id
  description = "VM ID"
}

output "vm_ipv4_address" {
  value       = proxmox_virtual_environment_vm.debian-docker-apps.ipv4_addresses[1][0]
  description = "VM IPv4 address"
}

