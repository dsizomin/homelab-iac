data "sops_file" "authentik_secrets_file" {
  source_file = "${path.root}/secrets/authentik.enc.env"
  input_type  = "dotenv"
}

resource "portainer_docker_secret" "authentik_db_password" {
  name            = "authentik_db_password"
  endpoint_id     = 1
  data_wo_version = 1
  data_wo         = base64encode(data.sops_file.authentik_secrets_file.data["AUTHENTIK_POSTGRESQL__PASSWORD"])
}

resource "portainer_docker_secret" "authentik_secret_key" {
  name            = "authentik_secret_key"
  endpoint_id     = 1
  data_wo_version = 1
  data_wo         = base64encode(data.sops_file.authentik_secrets_file.data["AUTHENTIK_SECRET_KEY"])
}

resource "portainer_stack" "portainer_authentik" {
  name            = "authentik"
  deployment_type = "swarm"
  method          = "string"
  endpoint_id     = 1

  stack_file_content = file("${path.root}/stacks/authentik/compose.yaml")

  depends_on = [
    portainer_docker_secret.authentik_db_password,
    portainer_docker_secret.authentik_secret_key
  ]
}
