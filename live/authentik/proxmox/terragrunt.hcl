include "root" {
  path = find_in_parent_folders("root.hcl")
}

include "providers" {
  path = find_in_parent_folders("authentik.hcl")
}

dependency "oidc_config" {
  config_path = "../../config/oidc"
}

dependency "dns_config" {
  config_path = "../../config/dns"
}

inputs = {
  name          = "proxmox"
  client_id     = dependency.oidc_config.outputs.client_id.proxmox
  client_type   = "public"
  redirect_uris = ["https://${dependency.dns_config.outputs.dns_config.services.proxmox}"]
}

terraform {
  source = "../../../modules//authentik/oidc_provider/"
}

