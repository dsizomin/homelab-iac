generate "grafana_provider" {
  path      = "providers_grafana.tf"
  if_exists = "overwrite_terragrunt"
  contents  = <<EOF
provider "grafana" {
  fleet_management_url = "https://fleet-management-prod-011.grafana.net/"
}
EOF
}
