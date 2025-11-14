output "content" {
  value       = data.cloudinit_config.cloud-init.rendered
  description = "Rendered cloud-init content for the Debian cloud-init configuration"
}
