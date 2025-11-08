output "oidc_config" {
  value       = data.authentik_provider_oauth2_config.config
  description = "The OIDC provider configuration details."
}

output "oidc_secret_key" {
  value       = authentik_provider_oauth2.this.client_secret
  sensitive   = true
  description = "The client secret for the OIDC provider."
}
