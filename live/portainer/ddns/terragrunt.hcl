include "root" {
  path = find_in_parent_folders("root.hcl")
}

include "providers" {
  path = find_in_parent_folders("providers.hcl")
}

locals {
  DDNS_CLOUDFLARE_API_KEY = yamldecode(sops_decrypt_file("sops.yaml"))["DDNS_CLOUDFLARE_API_KEY"]
}

inputs = {
  ddns_cloudflare_api_key = local.DDNS_CLOUDFLARE_API_KEY
}

terraform {
  source = "../../../modules/portainer/ddns"
}
