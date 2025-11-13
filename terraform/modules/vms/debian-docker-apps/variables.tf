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

variable "ipv4_address" {
  type    = string
  default = "dhcp"
}
