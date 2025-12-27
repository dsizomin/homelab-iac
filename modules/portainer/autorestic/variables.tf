variable "service_network" {
  type        = string
  description = "Docker network ID for the service network"
}

variable "healthchecks_ping_key" {
  type        = string
  description = "The ping key for Healthchecks"
  sensitive   = true
  ephemeral   = true
}

variable "dns_config" {
  type = object({
    zone     = string
    services = map(string)
    email    = string
  })
  description = "DNS configuration from the dns module"
}
