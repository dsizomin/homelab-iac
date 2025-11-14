variable "proxmox_endpoint" {
  type = string
}

variable "proxmox_token" {
  type      = string
  sensitive = true
  ephemeral = true
}

variable "node_name" {
  type    = string
  default = "pve"
}

variable "image_store" {
  type    = string
  default = "local"
}

variable "vm_store" {
  type    = string
  default = "local-lvm"
}

variable "username" {
  type = string
}

variable "ssh_pubkey" {
  type = string
}

variable "opkssh" {
  type = object({
    issuer    = string
    subject   = string
    client_id = string
  })
}

variable "ipv4_gateway" {
  type    = string
  default = "192.168.1.1"
}

variable "ipv4_addresses" {
  type = object({
    docker_apps = string
    hass        = string
  })
}

variable "portainer_password" {
  type      = string
  sensitive = true
}

variable "pulse_env" {
  type = object({
    public_url        = string
    oidc_enabled      = optional(bool)
    oidc_client_id    = optional(string)
    oidc_issuer_url   = optional(string)
    oidc_groups_claim = optional(string)
  })
}

variable "ddns_env" {
  type = object({
    subdomain = string
    zone      = string
  })
}

variable "opengist_env" {
  type = object({
    oidc_provider      = string
    oidc_client_key    = string
    oidc_discovery_url = string
    oidc_groups_claim  = string
    oidc_admin_group   = string
  })
}

variable "paperless_env" {
  type = object({
    paperless_url = string
    openid_connect = object({
      pkce_enabled = bool
      apps = list(object({
        name        = string
        provider_id = string
        client_id   = string
        settings = object({
          server_url = string
        })
      }))
    })
  })
}
