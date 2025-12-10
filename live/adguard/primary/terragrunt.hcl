include {
  path = find_in_parent_folders("root.hcl")
}

dependency "dns_config" {
  config_path = "../../config/dns"
}

dependency "reverse_proxy_host" {
  config_path = "../../infra/vms/docker-apps"
}

generate "adguard_provider" {
  path      = "providers_adguard_primary.tf"
  if_exists = "overwrite_terragrunt"

  contents = <<EOF
provider "adguard" {
  host     = "${dependency.dns_config.outputs.dns_servers.primary}"
  scheme   = "http"
  username = "${get_env("ADGUARD_USERNAME")}"
  password = "${get_env("ADGUARD_PASSWORD")}"
  insecure = true
}
EOF
}

inputs = {
  dns_config = dependency.dns_config.outputs.dns_config
  reverse_proxy_ip = dependency.reverse_proxy_host.outputs.ssh_host
}

terraform {
  source = "../../../modules//adguard"
}

