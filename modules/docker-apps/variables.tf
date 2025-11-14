variable "portainer_host" {
  type        = string
  description = "Portainer host"
}

variable "portainer_port" {
  type    = string
  default = "9443"
}

variable "username" {
  type        = string
  description = "SSH username"
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
