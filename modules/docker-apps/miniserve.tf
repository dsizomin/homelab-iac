resource "portainer_stack" "portainer-miniserve" {
  name            = "miniserve"
  deployment_type = "swarm"
  endpoint_id     = 1

  method                  = "repository"
  repository_url          = "https://github.com/dsizomin/homelab-iac.git"
  file_path_in_repository = "stacks/miniserve/compose.yaml"
}
