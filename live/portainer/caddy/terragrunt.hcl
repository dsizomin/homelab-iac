include "root" {
  path = find_in_parent_folders("root.hcl")
}

include "providers" {
  path = find_in_parent_folders("providers.hcl")
}

locals {
  ACME_CLOUDFLARE_API_KEY = yamldecode(sops_decrypt_file("sops.yaml"))["ACME_CLOUDFLARE_API_KEY"]
}

dependency "image" {
  config_path = "../../docker/images/caddy"
}

dependency "proxy_network" {
  config_path = "../../docker/networks/proxy"
}

dependency "dns_config" {
  config_path = "../../config/dns"
}


inputs = {
  acme_cloudflare_api_key = local.ACME_CLOUDFLARE_API_KEY
  image_id                = dependency.image.outputs.image_id
  proxy_network           = dependency.proxy_network.outputs.network_id
  dns_config     = dependency.dns_config.outputs.dns_config
}

terraform {
  source = "../../../modules/portainer/caddy"
}
