include "root" {
  path = find_in_parent_folders("root.hcl")
}

include "docker" {
  path = find_in_parent_folders("providers.hcl")
}

inputs = {
  network_name = "proxy_network"
}

terraform {
  source = "../../../../modules/docker/networks/overlay"
}
