include "root" {
  path = find_in_parent_folders("root.hcl")
}

include "proxmox" {
  path = find_in_parent_folders("providers.hcl")
}

terraform {
  source = "../../../../modules/infra/vms/debian-vm"
}

dependency "dns_config" {
  config_path = "../../../config/dns"
}

locals {
  username = "denys.sizomin"
  email = "denys.sizomin@gmail.com"
  ssh_pubkey = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIB/HJWec8QoIpsAIgQ7at7RrmjxxkGIPmkrwkKLb5yEx denys.sizomin@denys-sizomin-GK17KJ4VYD"
  opkssh_oidc_client_id = "mAvyAo9H61qLl74SXRSqY1rLXh3HhqkvgW3SCq6H"
  docker_cloud_config = <<EOF
#cloud-config
merge_how:
  - name: list
    settings: [append]
  - name: dict
    settings: [no_replace, recurse_list]

packages:
  - lazygit
  - ripgrep
  - fd-find
  - fzf
  - age

runcmd:
  - curl -LO https://github.com/neovim/neovim/releases/latest/download/nvim-linux-x86_64.appimage
  - chmod u+x nvim-linux-x86_64.appimage
  - ./nvim-linux-x86_64.appimage --appimage-extract
  - rm nvim-linux-x86_64.appimage
  - mv squashfs-root /opt/nvim
  - ln -s /opt/nvim/AppRun /usr/bin/nvim
  - curl -LO https://github.com/getsops/sops/releases/download/v3.11.0/sops-v3.11.0.linux.amd64
  - mv sops-v3.11.0.linux.amd64 /usr/local/bin/sops
  - chmod +x /usr/local/bin/sops
  - su - ${local.username} -c 'git clone https://github.com/dsizomin/dotfiles ~/.dotfiles'
  - su - ${local.username} -c 'ln -sf ~/.dotfiles/zsh/.zshrc ~/.zshrc'
  - su - ${local.username} -c 'ln -sf ~/.dotfiles/tmux/.tmux.conf ~/.tmux.conf'
  - su - ${local.username} -c 'mkdir -p ~/.config'
  - su - ${local.username} -c 'ln -sf ~/.dotfiles/nvim ~/.config/nvim'
  - su - ${local.username} -c 'ln -sf ~/.config/nvim/lua/default ~/.config/nvim/lua/plugins'
  - su - ${local.username} -c 'curl -o- https://raw.githubusercontent.com/nvm-sh/nvm/v0.40.3/install.sh | bash'
  - su - ${local.username} -c 'export NVM_DIR=\"$HOME/.nvm\" && [ -s \"$NVM_DIR/nvm.sh\" ] && . \"$NVM_DIR/nvm.sh\" && nvm install --lts && nvm use --lts'

EOF
}

inputs = {
  name        = "workbench"
  node_name   = "pve"
  vm_store    = "local-lvm"
  image_store = "local"

  username = local.username
  ssh_pubkey = local.ssh_pubkey

  opkssh = {
    issuer    = "https://auth.denyssizomin.com/application/o/opkssh/"
    client_id = local.opkssh_oidc_client_id
    subject   = local.email
  }

  cpu_cores    = 2
  memory_mb    = 4096
  disk_size_gb = 20

  ipv4_address = "192.168.1.55/24"
  ipv4_gateway = "192.168.1.1"
  dns_servers = [
    dependency.dns_config.outputs.dns_servers.primary,
    dependency.dns_config.outputs.dns_servers.secondary,
  ]

  tags = ["terraform", "vm"]

  cloud_init_parts = [{
    filename     = "workbench.yaml"
    content_type = "text/cloud-config"
    merge_type   = "list()+dict()+str()"
    content      = local.docker_cloud_config
  }]
}

