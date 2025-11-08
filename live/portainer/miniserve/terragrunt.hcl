include "root" {
  path = find_in_parent_folders("root.hcl")
}

include "providers" {
  path = find_in_parent_folders("providers.hcl")
}

dependency "proxy_network" {
  config_path = "../../docker/networks/proxy"
}

inputs = {
  proxy_network = dependency.proxy_network.outputs.network_id
}

terraform {
  source = "../../../modules/portainer/miniserve"
}

