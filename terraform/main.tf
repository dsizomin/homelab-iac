resource "proxmox_virtual_environment_download_file" "debian13" {
  node_name    = var.node_name
  datastore_id = var.image_store
  content_type = "iso"
  url          = "https://cloud.debian.org/images/cloud/trixie/latest/debian-13-genericcloud-amd64.qcow2"
  file_name    = "debian-13-genericcloud-amd64.img"
}

resource "proxmox_virtual_environment_file" "ci_user_data" {
  node_name    = var.node_name
  datastore_id = var.image_store
  content_type = "snippets"

  source_raw {
    file_name = "denys-user-data.yaml"
    data      = <<-EOT
      #cloud-config
      timezone: Europe/Amsterdam
      package_update: true
      package_upgrade: true
      package_reboot_if_required: true
      hostname: debian-apps

      users:
        - default
        - name: denys.sizomin
          sudo: ["ALL=(ALL) NOPASSWD:ALL"]
          groups: sudo
          shell: /usr/bin/zsh

      packages:
        - sudo
        - git
        - zsh
        - curl
        - wget
        - unzip
        - ca-certificates
        - qemu-guest-agent
        - net-tools
        - tmux
        - ripgrep
        - fd-find
        - fzf
        - lazygit
        - gcc
        - make

      runcmd:
        # start and enable qemu-guest-agent
        - systemctl enable qemu-guest-agent
        - systemctl start qemu-guest-agent
        # download and install neovim
        - curl -LO https://github.com/neovim/neovim/releases/latest/download/nvim-linux-x86_64.appimage
        - chmod u+x nvim-linux-x86_64.appimage
        - ./nvim-linux-x86_64.appimage --appimage-extract
        - rm nvim-linux-x86_64.appimage
        - mv squashfs-root /opt/nvim
        - ln -s /opt/nvim/AppRun /usr/bin/nvim
        # configure opkssh
        - bash -lc 'wget -qO- https://raw.githubusercontent.com/openpubkey/opkssh/main/scripts/install-linux.sh | bash'
        - bash -lc 'printf "%s %s %s\n" "https://auth.denyssizomin.com/application/o/opkssh/" "8wUTD5G5KgiyK7nXUHr7O2XK5EiR8iW1Pd2SqRWL" "24h" >> /etc/opk/providers'
        - su - denys.sizomin -c 'opkssh add denys.sizomin denys.sizomin@gmail.com https://auth.denyssizomin.com/application/o/opkssh/'
        - su - denys.sizomin -c "git clone ${var.dotfiles_repo} ~/.dotfiles"
        # setup dotfiles
        - su - denys.sizomin -c 'ln -sf ~/.dotfiles/zsh/.zshrc ~/.zshrc'
        - su - denys.sizomin -c 'mkdir -p ~/.config'
        - su - denys.sizomin -c 'ln -sf ~/.dotfiles/nvim ~/.config/nvim'
        - su - denys.sizomin -c 'ln -sf ~/.config/nvim/lua/slim ~/.config/nvim/lua/plugins'
        # setup NVM, NodeJS
        - su - denys.sizomin -c 'curl -o- https://raw.githubusercontent.com/nvm-sh/nvm/v0.40.3/install.sh | bash'
        - su - denys.sizomin -c 'export NVM_DIR="$HOME/.nvm" && [ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh" && nvm install --lts && nvm use --lts'
    EOT
  }
}

resource "proxmox_virtual_environment_vm" "debian-apps" {
  name      = "debian-apps-old"
  node_name = var.node_name
  started   = true
  tags      = ["debian", "terraform"]

  cpu {
    cores = 4
  }

  memory { dedicated = 8096 }

  agent { enabled = true }

  serial_device {
    device = "socket"
  }

  scsi_hardware = "virtio-scsi-single"

  disk {
    datastore_id = var.vm_store
    interface    = "scsi0"
    file_id      = proxmox_virtual_environment_download_file.debian13.id
    size         = 40
    iothread     = true
    discard      = "on"
  }


  network_device {
    bridge = var.bridge
  }

  initialization {
    datastore_id = var.vm_store

    ip_config {
      ipv4 {
        address = "dhcp"
      }
    }

    user_data_file_id = proxmox_virtual_environment_file.ci_user_data.id
  }
}

module "debian-apps-vm" {
  source      = "./modules/vms/debian-apps"
  node_name   = var.node_name
  image_store = var.image_store
  username    = var.username
  ssh_pubkey  = var.ssh_pubkey
  opkssh      = var.opkssh
}
