variable "ddns_cloudflare_api_key" {
  type        = string
  sensitive   = true
  ephemeral   = true
  description = "API key for Cloudflare to be used by DDNS service"
}

variable "dns_config" {
  type = object({
    zone     = string
    services = map(string)
    email    = string
  })
  description = "DNS configuration from the dns module"
}
