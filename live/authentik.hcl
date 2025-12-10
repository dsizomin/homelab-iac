dependency "dns_config" {
  config_path = "${path_relative_from_include()}/config/dns"
}

generate "authentik_provider" {
  path      = "providers_authentik.tf"
  if_exists = "overwrite_terragrunt"
  contents  = <<EOF
provider "authentik" {
  url   = "https://${dependency.dns_config.outputs.dns_config.services.auth}/"
}
EOF
}
