include "root" {
  path = find_in_parent_folders("root.hcl")
}

include "docker" {
  path = find_in_parent_folders("providers.hcl")
}

terraform {
  source = "../../../../modules/docker/images/caddy"
}

locals {
  caddyfile_content = file("Caddyfile")
}


inputs = {
  image_name = "homelab/caddy-cloudflare:latest"
  caddyfile  = local.caddyfile_content

  keep_locally     = true
}
