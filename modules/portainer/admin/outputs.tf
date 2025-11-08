output "username" {
  value       = var.username
  description = "The username for the Portainer admin user."
}

output "password" {
  value       = random_password.password.result
  sensitive   = true
  description = "The password for the Portainer admin user."
}
