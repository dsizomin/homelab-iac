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

variable "vm_flavour" {
  type = string
}

variable "disk_size" {
  type    = number
  default = 20
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

