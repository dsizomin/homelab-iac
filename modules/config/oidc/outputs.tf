output "client_id" {
  value = {
    for k, v in random_password.client_id : k => v.result
  }
  sensitive = true
  description = "OIDC Client IDs for all consumers"
}

