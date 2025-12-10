include "root" {
  path = find_in_parent_folders("root.hcl")
}

include "providers" {
  path = find_in_parent_folders("portainer.hcl")
}

include "authentik" {
  path = find_in_parent_folders("authentik.hcl")
}

dependency "oidc_config" {
  config_path = "../../config/oidc"
}

inputs = {  
  oidc_client_id     = dependency.oidc_config.outputs.client_id.portainer
  portainer_hostname = dependency.dns_config.outputs.dns_config.services.portainer
}

terraform {
  source = "../../../modules//portainer/settings"
}
