variable "zone" {
  type        = string
  description = "DNS zone name (e.g., example.com)"

  validation {
    condition     = can(regex("^[a-z0-9][a-z0-9-]*[a-z0-9]\\.[a-z]{2,}$", var.zone))
    error_message = "Zone must be a valid domain name (e.g., example.com)"
  }
}

variable "services" {
  type = map(object({
    subdomain   = string
    enabled     = optional(bool, true)
    description = optional(string, "")
  }))
  description = "Map of service names to their DNS configuration"
  default = {
    auth = {
      subdomain   = "auth"
      description = "Authentik SSO & Identity Provider"
    }
    paperless = {
      subdomain   = "paperless"
      description = "Paperless-ngx Document Management"
    }
    gist = {
      subdomain   = "gist"
      description = "OpenGist Code Snippet Sharing"
    }
    cdn = {
      subdomain   = "cdn"
      description = "Miniserve File Server"
    }
    pulse = {
      subdomain   = "pulse"
      description = "Pulse System Monitoring"
    }
    portainer = {
      subdomain   = "portainer"
      description = "Portainer Container Management"
    }
    proxmox = {
      subdomain   = "proxmox"
      description = "Proxmox VE Management"
    }
    hass = {
      subdomain   = "hass"
      description = "Home Assistant"
    }
    home = {
      subdomain   = "home"
      description = "Dynamic DNS entry"
    }
  }
}

variable "email_prefix" {
  type        = string
  description = "Email prefix for ACME notifications (e.g., 'me' for me@example.com)"
  default     = "me"
}

variable "dns_servers" {
  type = object({
    primary   = string
    secondary = string
  })
  description = "DNS server IP addresses"
  default = {
    primary   = "192.168.1.111",
    secondary = "192.168.1.222",
  }
}
