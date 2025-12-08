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
  healthchecks_ping_key = get_env("HEALTHCHECKS_PING_KEY", "")
}

terraform {
  source = "../../../modules//portainer/autorestic"
}

