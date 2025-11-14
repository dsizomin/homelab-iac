resource "docker_image" "caddy_image" {
  name         = "caddy_acme_cloudflare"
  keep_locally = true
  build {
    context        = "."
    remote_context = "https://github.com/dsizomin/homelab-iac.git#:/stacks/caddy"
  }
  triggers = {
    dir_sha1 = sha1(join("", [for f in fileset(path.root, "./stacks/caddy/**") : filesha1(f)]))
  }
}

data "sops_file" "acme_cloudflare_api_key_file" {
  source_file = "${path.root}/secrets/caddy.enc.env"
  input_type  = "dotenv"
}

resource "portainer_docker_secret" "acme_cloudflare_api_key" {
  name            = "acme_cloudflare_api_key"
  endpoint_id     = 1
  data_wo_version = 2
  data_wo         = base64encode(data.sops_file.acme_cloudflare_api_key_file.data["ACME_CLOUDFLARE_API_KEY"])
}

resource "portainer_stack" "portainer_caddy" {
  name            = "caddy"
  deployment_type = "swarm"
  endpoint_id     = 1

  method                  = "repository"
  repository_url          = "https://github.com/dsizomin/homelab-iac.git"
  file_path_in_repository = "stacks/caddy/compose.yaml"

  env {
    name  = "IMAGE"
    value = docker_image.caddy_image.image_id
  }

  depends_on = [
    portainer_docker_secret.acme_cloudflare_api_key,
  ]
}

