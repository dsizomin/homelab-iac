terraform {
  required_version = ">= 1.6"
}

locals {
  # Generate FQDNs for all enabled services
  service_fqdns = {
    for k, v in var.services :
    k => "${v.subdomain}.${var.zone}" if v.enabled
  }

  # Generate ACME email
  acme_email = "${var.email_prefix}@${var.zone}"
}

