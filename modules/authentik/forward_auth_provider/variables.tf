variable "name" {
  type        = string
  description = "The name of the provider."
}

variable "external_host" {
  type        = string
  description = "The external host URL for the forward auth provider."
}

variable "skip_path_regex" {
  type        = string
  description = "Regex pattern for paths to skip authentication."
  default     = ""
}
