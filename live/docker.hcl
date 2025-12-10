dependency "docker_host" {
  config_path = "${path_relative_from_include()}/infra/vms/docker-apps"
}

generate "docker_provider" {
  path      = "providers_docker.tf"
  if_exists = "overwrite_terragrunt"

  contents = <<EOF
provider "docker" {
  host = "ssh://${dependency.docker_host.outputs.ssh_host}:22"
  ssh_opts = ["-o", "StrictHostKeyChecking=no", "-o", "UserKnownHostsFile=/dev/null"]
}
EOF
}

