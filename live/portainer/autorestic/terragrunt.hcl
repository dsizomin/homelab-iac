include "root" {
  path = find_in_parent_folders("root.hcl")
}

include "providers" {
  path = find_in_parent_folders("portainer.hcl")
}

dependency "proxy_network" {
  config_path = "../../docker/networks/proxy"
}

dependency "dns_config" {
  config_path = "../../config/dns"
}

inputs = {
  proxy_network = dependency.proxy_network.outputs.network_id
  dns_config    = dependency.dns_config.outputs.dns_config
  healthchecks_ping_key = get_env("HEALTHCHECKS_PING_KEY", "")
}

terraform {
  source = "../../../modules//portainer/autorestic"
}

