data "sops_file" "opengist_oidc_secret_file" {
  source_file = "${path.root}/secrets/opengist.enc.env"
  input_type  = "dotenv"
}


resource "portainer_docker_secret" "opengist_secrets" {
  name            = "opengist_secrets"
  endpoint_id     = 1
  data_wo_version = 1
  data_wo         = base64encode(data.sops_file.opengist_oidc_secret_file.raw)
}

resource "portainer_stack" "portainer_opengist" {
  name            = "opengist"
  deployment_type = "swarm"
  endpoint_id     = 1

  method                  = "repository"
  repository_url          = "https://github.com/dsizomin/homelab-iac.git"
  file_path_in_repository = "stacks/opengist/compose.yaml"

  env {
    name  = "OG_OIDC_PROVIDER_NAME"
    value = var.opengist_env.oidc_provider
  }

  env {
    name  = "OG_OIDC_CLIENT_KEY"
    value = var.opengist_env.oidc_client_key
  }

  env {
    name  = "OG_OIDC_DISCOVERY_URL"
    value = var.opengist_env.oidc_discovery_url
  }

  env {
    name  = "OG_OIDC_GROUP_CLAIM_NAME"
    value = var.opengist_env.oidc_groups_claim
  }

  env {
    name  = "OG_OIDC_ADMIN_GROUP"
    value = var.opengist_env.oidc_admin_group
  }
}
