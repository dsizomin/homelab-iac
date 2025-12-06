variable "image_name" {
  type        = string
  description = "Name (including tag) for the resulting Caddy image, e.g. homelab/caddy-cloudflare:latest."
}

variable "keep_locally" {
  type        = bool
  default     = true
  description = "Whether to keep the image locally after use."
}
