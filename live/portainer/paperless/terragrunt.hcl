include "root" {
  path = find_in_parent_folders("root.hcl")
}

include "providers" {
  path = find_in_parent_folders("providers.hcl")
}

dependency "oidc_config" {
  config_path = "../../config/oidc"
}

dependency "proxy_network" {
  config_path = "../../docker/networks/proxy"
}

dependency "dns_config" {
  config_path = "../../config/dns"
}

generate "providers_authentik" {
  path      = "providers_authentik.tf"
  if_exists = "overwrite_terragrunt"
  contents  = <<EOF
provider "authentik" {
  url   = "https://auth.denyssizomin.com/"
}
EOF
}

inputs = {
  proxy_network  = dependency.proxy_network.outputs.network_id
  oidc_client_id = dependency.oidc_config.outputs.client_id.paperless
  dns_config     = dependency.dns_config.outputs.dns_config
}

terraform {
  source = "../../../modules//portainer/paperless"
}

