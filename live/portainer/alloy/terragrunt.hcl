include "root" {
  path = find_in_parent_folders("root.hcl")
}

include "portainer" {
  path = find_in_parent_folders("portainer.hcl")
}

include "grafana" {
  path = find_in_parent_folders("grafana.hcl")
}

dependency "service_network" {
  config_path = "../../docker/networks/service"
}

dependency "proxy_network" {
  config_path = "../../docker/networks/proxy"
}

inputs = {
  service_network = dependency.service_network.outputs.network_id
  proxy_network   = dependency.proxy_network.outputs.network_id
  grafana_api_key = get_env("GRAFANA_ALLOY_API_KEY")
}

terraform {
  source = "../../../modules/portainer/alloy/"
}
