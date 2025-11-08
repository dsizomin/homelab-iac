generate "providers" {
  path      = "providers.tf"
  if_exists = "overwrite_terragrunt"
  contents  = <<EOF
provider "proxmox" {
  endpoint  = "${get_env("PROXMOX_ENDPOINT")}"
  api_token = "${get_env("PROXMOX_API_TOKEN")}"
  insecure  = true

  ssh {
    username    = "root"
    agent       = true
    private_key = file("~/.ssh/homelab")
  }
}
EOF
}

