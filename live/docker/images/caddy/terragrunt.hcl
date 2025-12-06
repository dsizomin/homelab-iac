include "root" {
  path = find_in_parent_folders("root.hcl")
}

include "docker" {
  path = find_in_parent_folders("providers.hcl")
}

dependency "dns_config" {
  config_path = "../../../config/dns"
}

terraform {
  source = "../../../../modules/docker/images/caddy"
}

inputs = {
  image_name = "homelab/caddy-cloudflare:latest"
  caddyfile  = templatefile("${get_terragrunt_dir()}/Caddyfile.tftpl", {
    email           = dependency.dns_config.outputs.dns_config.email
    auth_fqdn       = dependency.dns_config.outputs.dns_config.services.auth
    paperless_fqdn  = dependency.dns_config.outputs.dns_config.services.paperless
    gist_fqdn       = dependency.dns_config.outputs.dns_config.services.gist
    cdn_fqdn        = dependency.dns_config.outputs.dns_config.services.cdn
    pulse_fqdn      = dependency.dns_config.outputs.dns_config.services.pulse
    proxmox_fqdn    = dependency.dns_config.outputs.dns_config.services.proxmox
    hass_fqdn       = dependency.dns_config.outputs.dns_config.services.hass
    portainer_fqdn  = dependency.dns_config.outputs.dns_config.services.portainer
    vault_fqdn      = dependency.dns_config.outputs.dns_config.services.vault
  })
  keep_locally = true
}
