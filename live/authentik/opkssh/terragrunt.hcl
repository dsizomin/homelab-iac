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
  name          = "opkssh"
  client_id     = dependency.oidc_config.outputs.client_id.opkssh
  client_type   = "public"
  redirect_uris = ["http://127.0.0.1:5555"]
}

terraform {
  source = "../../../modules//authentik/oidc_provider/"
}

