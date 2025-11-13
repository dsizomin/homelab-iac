variable "node_name" {
  type    = string
  default = "pve"
}

variable "image_store" {
  type    = string
  default = "local"
}

variable "vm_store" {
  type    = string
  default = "local-lvm"
}

variable "cloud_init_parts" {
  type = list(object({
    content      = string
    content_type = optional(string)
    filename     = optional(string)
    merge_type   = optional(string)
  }))
  default = []
}

variable "hostname" {
  type = string
}

variable "username" {
  type = string
}

variable "ssh_pubkey" {
  type = string
}

variable "opkssh" {
  type = object({
    issuer    = string
    subject   = string
    client_id = string
  })
}

