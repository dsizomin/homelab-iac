include "root" {
  path = find_in_parent_folders("root.hcl")
}

include "docker" {
  path = find_in_parent_folders("providers.hcl")
}

dependency "proxy_network" {
  config_path = "../../networks/proxy"
}

terraform {
  source = "../../../../modules/docker/services/portainer"
}

inputs = {
  proxy_network_id = dependency.proxy_network.outputs.network_id
}
