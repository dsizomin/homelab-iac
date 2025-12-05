variable "proxy_network" {
  type        = string
  description = "Docker network ID for the proxy network"
}

variable "oidc_client_id" {
  type        = string
  description = "The client ID for the Pulse OIDC provider."
}

variable "dns_config" {
  type = object({
    zone     = string
    services = map(string)
    email    = string
  })
  description = "DNS configuration from the dns module"
}
