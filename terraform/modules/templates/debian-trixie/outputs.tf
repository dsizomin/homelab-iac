output "template_vm_id" {
  description = "The ID of the Debian template VM."
  value       = proxmox_virtual_environment_vm.debian-template.id
}
