output "vm_name" {
  value       = proxmox_virtual_environment_vm.this.name
  description = "Name of the VM"
}

output "vmid" {
  value       = proxmox_virtual_environment_vm.this.vm_id
  description = "Proxmox VM ID"
}

output "node_name" {
  value       = proxmox_virtual_environment_vm.this.node_name
  description = "Proxmox node name"
}

output "ipv4_address" {
  value       = var.ipv4_address
  description = "Configured IPv4 address for Home Assistant VM"
}
