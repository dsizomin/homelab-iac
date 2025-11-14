resource "portainer_stack" "portainer-pulse" {
  name            = "pulse"
  deployment_type = "swarm"
  endpoint_id     = 1

  method                  = "repository"
  repository_url          = "https://github.com/dsizomin/homelab-iac.git"
  file_path_in_repository = "stacks/pulse/compose.yaml"

  env {
    name  = "PULSE_PUBLIC_URL"
    value = var.pulse_env.public_url
  }

  env {
    name  = "OIDC_ENABLED"
    value = var.pulse_env.oidc_enabled
  }

  env {
    name  = "OIDC_CLIENT_ID"
    value = var.pulse_env.oidc_client_id
  }
  env {
    name  = "OIDC_ISSUER_URL"
    value = var.pulse_env.oidc_issuer_url
  }
  env {
    name  = "OIDC_GROUPS_CLAIM"
    value = var.pulse_env.oidc_groups_claim
  }
}

