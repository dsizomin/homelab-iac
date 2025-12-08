output "network_id" {
  description = "The ID of the Docker network"
  value       = docker_network.this.id
}
