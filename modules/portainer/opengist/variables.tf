variable "proxy_network" {
  type        = string
  description = "Docker network ID for the proxy network"
}

variable "oidc_client_id" {
  type        = string
  description = "The client ID for the  Opengist OIDC provider."
}
