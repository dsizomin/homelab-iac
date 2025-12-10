include "root" {
  path = find_in_parent_folders("root.hcl")
}

include "docker" {
  path = find_in_parent_folders("docker.hcl")
}

dependency "proxy_network" {
  config_path = "../../networks/proxy"
}

dependency "dns_config" {
  config_path = "../../../config/dns"
}

terraform {
  source = "../../../../modules/docker/services/portainer"
}

inputs = {
  proxy_network_id = dependency.proxy_network.outputs.network_id
  dns_config    = dependency.dns_config.outputs.dns_config
}
