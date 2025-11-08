output "image_name" {
  value       = docker_image.caddy.name
  description = "Name of the built Caddy image."
}

output "image_id" {
  value       = docker_image.caddy.image_id
  description = "Docker image ID."
}

output "repo_digest" {
  value       = docker_image.caddy.repo_digest
  description = "Repo digest of the built image, if available."
}

