variable "hostname" {
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

variable "extra_packages" {
  type        = list(string)
  default     = []
  description = "Additional OS packages to install on top of the core set."
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

