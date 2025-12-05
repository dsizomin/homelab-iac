include "root" {
  path = find_in_parent_folders("root.hcl")
}

inputs = {
  zone = "denyssizomin.com"
}

terraform {
  source = "../../../modules//config/dns"
}

