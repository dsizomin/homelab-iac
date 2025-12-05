dependency "dns_config" {
  config_path = "../../config/dns"
}

generate "providers" {
  path      = "providers.tf"
  if_exists = "overwrite_terragrunt"
  contents  = <<EOF
provider "authentik" {
  url   = "https://${dependency.dns_config.outputs.dns_config.services.auth}/"
}
EOF
}
