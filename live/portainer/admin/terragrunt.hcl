include "root" {
  path = find_in_parent_folders("root.hcl")
}

include "providers" {
  path = find_in_parent_folders("providers.hcl")
}

dependency "docker_host" {
  config_path = "../../../live/infra/vms/docker-apps"
}

terraform {
  source = "../../../modules/portainer/admin"
}
