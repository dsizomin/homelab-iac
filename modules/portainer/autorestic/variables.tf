variable "proxy_network" {
  type        = string
  description = "Docker network ID for the proxy network"
}

variable "healthchecks_ping_key" {
  type        = string
  description = "The ping key for Healthchecks"
  sensitive   = true
  ephemeral   = true
}
