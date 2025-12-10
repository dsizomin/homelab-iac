include "root" {
  path = find_in_parent_folders("root.hcl")
}

include "docker" {
  path = find_in_parent_folders("docker.hcl")
}

inputs = {
  network_name = "service_network"
}

terraform {
  source = "../../../../modules/docker/networks/overlay"
}
