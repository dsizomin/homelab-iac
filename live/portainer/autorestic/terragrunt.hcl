include "root" {
  path = find_in_parent_folders("root.hcl")
}

include "providers" {
  path = find_in_parent_folders("providers.hcl")
}

dependency "cronjob" {
  config_path = "../cronjob"
}

inputs = {
  cronjob_network_id = dependency.cronjob.outputs.network_id
}

terraform {
  source = "../../../modules//portainer/autorestic"
}

