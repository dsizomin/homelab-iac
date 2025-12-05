output "dns_config" {
  description = "Combined DNS configuration for use by other modules"
  value = {
    zone     = var.zone
    services = local.service_fqdns
    email    = local.acme_email
  }
}

