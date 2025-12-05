include "root" {
  path = find_in_parent_folders("root.hcl")
}

include "proxmox" {
  path = find_in_parent_folders("providers.hcl")
}

dependency "oidc_config" {
  config_path = "../../../config/oidc"
}

dependency "dns_config" {
  config_path = "../../../config/dns"
}

terraform {
  source = "../../../../modules/infra/vms/debian-vm"
}

locals {
  username = "denys.sizomin"
  email = "denys.sizomin@gmail.com"
  docker_cloud_config = <<EOF
#cloud-config
merge_how:
  - name: list
    settings: [append]
  - name: dict
    settings: [no_replace, recurse_list]

apt:
  sources:
    download-docker-com.list:
      source: "deb https://download.docker.com/linux/debian trixie stable"
      key: |
        ${indent(8, file("${get_terragrunt_dir()}/docker.gpg"))}
        
packages:
  - docker-ce
  - docker-ce-cli
  - containerd.io
  - docker-buildx-plugin
  - docker-compose-plugin

groups:
  - docker

runcmd:
  - usermod -aG docker ${local.username}
  - systemctl enable docker
  - systemctl start docker
  - docker swarm init || true
  - bash -c 'mkdir -p /srv/data/{authentik,miniserve,portainer,opengist,paperless,pulse}'
  - chown -R ${local.username}:${local.username} /srv/data
EOF
}

inputs = {
  name        = "docker-apps"
  node_name   = "pve"
  vm_store    = "local-lvm"
  image_store = "local"

  username = local.username
  ssh_pubkey = file("~/.ssh/homelab.pub")

  opkssh = {
    issuer    = "https://auth.denyssizomin.com/application/o/opkssh/"
    client_id = dependency.oidc_config.outputs.client_id.opkssh
    subject   = local.email
  }

  cpu_cores    = 2
  memory_mb    = 4096
  disk_size_gb = 20

  ipv4_address = "192.168.1.99/24"
  ipv4_gateway = "192.168.1.1"
  dns_servers  = [
    dependency.dns_config.outputs.dns_servers.primary,
    dependency.dns_config.outputs.dns_servers.secondary,
  ]

  tags = ["terraform", "docker", "vm"]

  cloud_init_parts = [{
    filename     = "docker-apps.yaml"
    content_type = "text/cloud-config"
    merge_type   = "list()+dict()+str()"
    content      = local.docker_cloud_config
  }]
}

