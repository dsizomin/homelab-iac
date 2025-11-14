data "sops_file" "paperless_secrets_file" {
  source_file = "${path.root}/secrets/paperless.enc.env"
  input_type  = "dotenv"
}

resource "portainer_docker_secret" "paperless_db_password" {
  name        = "paperless_db_password"
  endpoint_id = 1

  data_wo_version = 1
  data_wo         = base64encode(data.sops_file.paperless_secrets_file.data["PAPERLESS_DBPASS"])
}

resource "portainer_docker_secret" "paperless_secret_key" {
  name        = "paperless_secret_key"
  endpoint_id = 1

  data_wo_version = 1
  data_wo         = base64encode(data.sops_file.paperless_secrets_file.data["PAPERLESS_SECRET_KEY"])
}

resource "portainer_stack" "portainer_paperless" {
  name            = "paperless"
  deployment_type = "swarm"
  method          = "string"
  endpoint_id     = 1

  stack_file_content = file("${path.root}/stacks/paperless/compose.yaml")

  env {
    name  = "PAPERLESS_URL"
    value = var.paperless_env.paperless_url
  }

  env {
    name = "PAPERLESS_SOCIALACCOUNT_PROVIDERS"
    value = jsonencode({
      openid_connect = {
        OAUTH_PKCE_ENABLED = var.paperless_env.openid_connect.pkce_enabled
        APPS               = var.paperless_env.openid_connect.apps
      }
    })

  }

  depends_on = [
    portainer_docker_secret.paperless_db_password,
    portainer_docker_secret.paperless_secret_key
  ]
}
