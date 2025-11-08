output "user_data" {
  value       = data.cloudinit_config.cloud_init.rendered
  description = "Rendered cloud-init user-data to pass to your VM resource."
}
