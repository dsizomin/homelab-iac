variable "dns_config" {
  type = object({
    zone     = string
    services = map(string)
    email    = string
  })
  description = "DNS configuration from the dns module"
}

variable "reverse_proxy_ip" {
  type        = string
  description = "The IP address of the reverse proxy"
}
