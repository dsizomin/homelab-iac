output "vm_id" {
  value       = proxmox_virtual_environment_vm.this.vm_id
  description = "Proxmox VM ID."
}

output "vm_name" {
  value       = proxmox_virtual_environment_vm.this.name
  description = "VM name / hostname."
}

output "node_name" {
  value       = proxmox_virtual_environment_vm.this.node_name
  description = "Proxmox node name."
}

output "ipv4_address_cidr" {
  value       = var.ipv4_address
  description = "Configured IPv4 address (CIDR)."
}

output "ssh_host" {
  value       = split("/", var.ipv4_address)[0]
  description = "IPv4 address without CIDR, convenient for SSH."
}

