variable "grafana_api_key" {
  type        = string
  description = "API key for Grafana Cloud access."
  sensitive   = true
  ephemeral   = true
}

variable "service_network" {
  type        = string
  description = "The ID of the service network to deploy resources into."
}

variable "proxy_network" {
  type        = string
  description = "The ID of the proxy network to deploy resources into."
}
