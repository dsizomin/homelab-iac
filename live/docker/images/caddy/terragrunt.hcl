include "root" {
  path = find_in_parent_folders("root.hcl")
}

include "docker" {
  path = find_in_parent_folders("providers.hcl")
}

terraform {
  source = "../../../../modules/docker/images/caddy"
}

inputs = {
  image_name = "homelab/caddy-cloudflare:latest"
  keep_locally = true
}
