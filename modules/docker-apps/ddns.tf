data "sops_file" "ddns_cloudflare_api_key_file" {
  source_file = "${path.root}/secrets/ddns.enc.env"
  input_type  = "dotenv"
}

resource "portainer_docker_secret" "ddns_cloudflare_api_key" {
  name            = "ddns_cloudflare_api_key"
  endpoint_id     = 1
  data_wo_version = 1
  data_wo         = base64encode(data.sops_file.ddns_cloudflare_api_key_file.data["DDNS_CLOUDFLARE_API_KEY"])
}

resource "portainer_stack" "portainer-ddns" {
  name            = "ddns"
  deployment_type = "swarm"
  endpoint_id     = 1

  method                  = "repository"
  repository_url          = "https://github.com/dsizomin/homelab-iac.git"
  file_path_in_repository = "stacks/ddns/compose.yaml"

  env {
    name  = "ZONE"
    value = var.ddns_env.zone
  }

  env {
    name  = "SUBDOMAIN"
    value = var.ddns_env.subdomain
  }

  depends_on = [
    data.sops_file.ddns_cloudflare_api_key_file,
  ]
}
