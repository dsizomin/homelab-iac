output "network_id" {
  description = "The ID of the created Docker network for the cronjob."
  value       = portainer_docker_network.cronjob.id
}
