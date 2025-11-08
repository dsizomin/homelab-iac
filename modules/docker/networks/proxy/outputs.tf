output "network_id" {
  description = "The ID of the Docker proxy network"
  value       = docker_network.proxy_network.id
}
