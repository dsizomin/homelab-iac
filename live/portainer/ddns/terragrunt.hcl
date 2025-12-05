include "root" {
  path = find_in_parent_folders("root.hcl")
}

include "providers" {
  path = find_in_parent_folders("providers.hcl")
}

dependency "dns_config" {
  config_path = "../../config/dns"
}

locals {
  DDNS_CLOUDFLARE_API_KEY = yamldecode(sops_decrypt_file("sops.yaml"))["DDNS_CLOUDFLARE_API_KEY"]
}

inputs = {
  ddns_cloudflare_api_key = local.DDNS_CLOUDFLARE_API_KEY
  dns_config              = dependency.dns_config.outputs.dns_config
}

terraform {
  source = "../../../modules/portainer/ddns"
}
