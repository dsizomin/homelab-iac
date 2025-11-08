variable "proxmox_endpoint" {
  type = string
}

variable "proxmox_token" {
  type      = string
  sensitive = true
}

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

variable "dotfiles_repo" {
  type    = string
  default = "https://github.com/dsizomin/dotfiles"
}

variable "bridge" {
  type    = string
  default = "vmbr0"
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

