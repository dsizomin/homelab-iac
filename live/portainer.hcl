dependency "docker_host" {
  config_path = "${path_relative_from_include()}/infra/vms/docker-apps"
}

generate "protainer_provider" {
  path      = "providers_portainer.tf"
  if_exists = "overwrite_terragrunt"
  contents  = <<EOF
provider "portainer" {
  endpoint = "https://${dependency.docker_host.outputs.ssh_host}:9443/api"
  api_key  = "${get_env("PORTAINER_API_KEY", "mock_api_key")}"
  skip_ssl_verify  = true
}
EOF
}
