variable "acme_cloudflare_api_key" {
  type        = string
  sensitive   = true
  ephemeral   = true
  description = "API key for Cloudflare to be used by Caddy for ACME DNS challenges"
}

variable "image_id" {
  type        = string
  description = "Docker image ID for Caddy"
}

variable "proxy_network" {
  type        = string
  description = "Docker network ID for the proxy network"
}

variable "dns_config" {
  type = object({
    zone     = string
    services = map(string)
    email    = string
  })
  description = "DNS configuration from the dns module"
}
