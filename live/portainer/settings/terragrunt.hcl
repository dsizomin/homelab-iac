include "root" {
  path = find_in_parent_folders("root.hcl")
}

include "providers" {
  path = find_in_parent_folders("providers.hcl")
}

dependency "oidc_config" {
  config_path = "../../config/oidc"
}

dependency "dns_config" {
  config_path = "../../config/dns"
}

inputs = {
  oidc_client_id     = dependency.oidc_config.outputs.client_id.portainer
  portainer_hostname = "portainer.denyssizomin.com"
}

generate "providers_authentik" {
  path      = "providers_authentik.tf"
  if_exists = "overwrite_terragrunt"
  contents  = <<EOF
provider "authentik" {
  url   = "https://${dependency.dns_config.outputs.dns_config.services.auth}/"
}
EOF
}

terraform {
  source = "../../../modules//portainer/settings"
}
