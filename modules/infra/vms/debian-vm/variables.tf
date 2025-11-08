variable "node_name" {
  type = string
}

variable "image_store" {
  type = string
}

variable "vm_store" {
  type = string
}

variable "name" {
  type        = string
  description = "Hostname to configure via cloud-init."
}

variable "username" {
  type        = string
  description = "Primary user to create/configure."
}

variable "ssh_pubkey" {
  type        = string
  description = "SSH public key for the primary user."
}

variable "opkssh" {
  type = object({
    issuer    = string
    client_id = string
    subject   = string
  })
  description = "OPKSSH provider configuration used for /etc/opk/providers and initial opkssh add."
}

variable "timezone" {
  type        = string
  default     = "Europe/Amsterdam"
  description = "Timezone for the VM."
}

variable "cloud_init_parts" {
  description = <<EOT
Additional cloud-init parts to merge into the final config.

Each element should be an object:
{
  filename     = "my-extra.yaml"
  content_type = "text/cloud-config" or "text/x-shellscript" etc.
  merge_type   = "list()+dict()+str()" (or other, if needed)
  content      = "<raw YAML or script content>"
}
EOT

  type = list(object({
    filename     = string
    content_type = string
    merge_type   = string
    content      = string
  }))

  default = []
}

variable "cpu_cores" {
  type        = number
  default     = 1
  description = "Number of CPU cores"
}

variable "cpu_type" {
  type        = string
  default     = "x86-64-v2-AES"
  description = "CPU type (see Proxmox CPU types)"
}

variable "memory_mb" {
  type        = number
  default     = 4096
  description = "RAM in MB"
}

variable "disk_size_gb" {
  type        = number
  default     = 32
  description = "Root disk size in GB"
}

variable "ipv4_address" {
  type        = string
  default     = "dhcp"
  description = "IPv4 address in CIDR (e.g. 192.168.1.50/24) or 'dhcp'"
}

variable "ipv4_gateway" {
  type        = string
  default     = null
  description = "IPv4 gateway address (null for DHCP)"
}

variable "dns_servers" {
  type        = list(string)
  default     = ["1.1.1.1", "9.9.9.9"]
  description = "DNS servers for the VM"
}

variable "auto_start" {
  type        = bool
  default     = true
  description = "Power on the VM after creation"
}

variable "tags" {
  type        = list(string)
  default     = ["terraform", "debian", "vm"]
  description = "Proxmox VM tags"
}
