variable "name" {
  type        = string
  description = "The name of the OIDC provider."
}

variable "client_id" {
  type        = string
  description = "The client ID for the OIDC provider."
}

variable "client_type" {
  type        = string
  description = "The client type for the OIDC provider (e.g., confidential or public)."
  default     = "public"
}

variable "redirect_uris" {
  type        = list(string)
  description = "A list of redirect URIs for the OIDC provider."
}
