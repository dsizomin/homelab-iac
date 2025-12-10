variable "proxy_network_id" {
  description = "The ID of the Docker proxy network."
  type        = string
}

variable "dns_config" {
  type = object({
    zone     = string
    services = map(string)
    email    = string
  })
  description = "DNS configuration from the dns module"
}
