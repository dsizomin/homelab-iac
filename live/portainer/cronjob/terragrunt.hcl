include "root" {
  path = find_in_parent_folders("root.hcl")
}

include "providers" {
  path = find_in_parent_folders("portainer.hcl")
}

include "authentik" {
  path = find_in_parent_folders("authentik.hcl")
}

dependency "proxy_network" {
  config_path = "../../docker/networks/proxy"
}

dependency "service_network" {
  config_path = "../../docker/networks/service"
}

dependency "dns_config" {
  config_path = "../../config/dns"
}

inputs = {
  service_network = dependency.service_network.outputs.network_id
  proxy_network = dependency.proxy_network.outputs.network_id
  dns_config   = dependency.dns_config.outputs.dns_config
}

terraform {
  source = "../../../modules//portainer/cronjob"
}

