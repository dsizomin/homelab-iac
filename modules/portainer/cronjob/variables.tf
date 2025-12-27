variable "proxy_network" {
  type        = string
  description = "Docker network ID for the proxy network"
}

variable "service_network" {
  type        = string
  description = "Docker network ID for the service network"

}

variable "dns_config" {
  type = object({
    zone     = string
    services = map(string)
    email    = string
  })
  description = "DNS configuration from the dns module"
}
