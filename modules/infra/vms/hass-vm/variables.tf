variable "name" {
  type        = string
  description = "VM name (e.g., ha01)"
}

variable "node_name" {
  type        = string
  description = "Proxmox node name (e.g., pve1)"
}

variable "image_store" {
  type = string
}

variable "vm_store" {
  type        = string
  description = "Proxmox datastore ID to store VM disk and cloud-init data"
}

variable "cpu_cores" {
  type        = number
  default     = 2
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
  default     = ["terraform", "homeassistant"]
  description = "Proxmox VM tags"
}
