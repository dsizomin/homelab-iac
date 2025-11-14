resource "portainer_stack" "portainer-miniserve" {
  name            = "miniserve"
  deployment_type = "swarm"
  method          = "string"
  endpoint_id     = 1

  stack_file_content = file("${path.root}/stacks/miniserve/compose.yaml")
}
