generate "proxmox_provider" {
  path      = "providers_proxmox.tf"
  if_exists = "overwrite_terragrunt"
  contents  = <<EOF
provider "proxmox" {
  endpoint  = "${get_env("PROXMOX_ENDPOINT")}"
  api_token = "${get_env("PROXMOX_API_TOKEN")}"
  insecure  = true

  ssh {
    username    = "root"
    agent       = true
  }
}
EOF
}

