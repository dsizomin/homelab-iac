terraform {
  required_version = ">= 1.8.0"
  required_providers {
    cloudinit = {
      source  = "hashicorp/cloudinit"
      version = "~> 2.3"
    }
  }
}

locals {
  merge_how = [
    {
      name     = "list"
      settings = ["append"]
    },
    {
      name     = "dict"
      settings = ["no_replace", "recurse_list"]
    },
  ]

  core_packages = [
    "git",
    "zsh",
    "curl",
    "wget",
    "unzip",
    "ca-certificates",
    "qemu-guest-agent",
    "net-tools",
    "tmux",
    # "ripgrep",
    # "fd-find",
    # "fzf",
    # "lazygit",
    "gcc",
    "make",
  ]

  users = [
    "default",
    {
      name                = var.username
      sudo                = ["ALL=(ALL) NOPASSWD:ALL"]
      shell               = "/usr/bin/zsh"
      groups              = "sudo"
      ssh_authorized_keys = [var.ssh_pubkey]
    },
  ]

  groups = [
    "opksshuser",
  ]

  write_files = [
    {
      path        = "/etc/opk/providers"
      content     = "${var.opkssh.issuer} ${var.opkssh.client_id} 24h\n"
      defer       = true
      append      = true
      owner       = "root:opksshuser"
      permissions = "640"
    },
  ]

  base_runcmd = [
    # "curl -LO https://github.com/neovim/neovim/releases/latest/download/nvim-linux-x86_64.appimage",
    # "chmod u+x nvim-linux-x86_64.appimage",
    # "./nvim-linux-x86_64.appimage --appimage-extract",
    # "rm nvim-linux-x86_64.appimage",
    # "mv squashfs-root /opt/nvim",
    # "ln -s /opt/nvim/AppRun /usr/bin/nvim",

    "opkssh add ${var.username} ${var.opkssh.subject} ${var.opkssh.issuer}",

    # "su - ${var.username} -c \"git clone https://github.com/dsizomin/dotfiles ~/.dotfiles\"",
    # "su - ${var.username} -c 'ln -sf ~/.dotfiles/zsh/.zshrc ~/.zshrc'",
    # "su - ${var.username} -c 'ln -sf ~/.dotfiles/tmux/.tmux.conf ~/.tmux.conf'",
    # "su - ${var.username} -c 'mkdir -p ~/.config'",
    # "su - ${var.username} -c 'ln -sf ~/.dotfiles/nvim ~/.config/nvim'",
    # "su - ${var.username} -c 'ln -sf ~/.config/nvim/lua/slim ~/.config/nvim/lua/plugins'",
  ]
}

data "cloudinit_config" "cloud_init" {
  gzip          = false
  base64_encode = false

  part {
    content_type = "text/cloud-config"
    merge_type   = "list()+dict()+str()"

    content = yamlencode({
      merge_how                  = local.merge_how
      timezone                   = var.timezone
      package_update             = true
      package_upgrade            = true
      package_reboot_if_required = true
      hostname                   = var.hostname
      users                      = local.users
      groups                     = local.groups
      write_files                = local.write_files
      packages                   = concat(local.core_packages, var.extra_packages)
      runcmd                     = local.base_runcmd
    })
  }

  dynamic "part" {
    for_each = var.cloud_init_parts

    content {
      content_type = part.value.content_type
      content      = part.value.content
      filename     = part.value.filename
      merge_type   = part.value.merge_type
    }
  }

  part {
    content_type = "text/cloud-config"
    merge_type   = "list()+dict()+str()"

    content = yamlencode({
      merge_how = local.merge_how
      runcmd = [
        "systemctl enable qemu-guest-agent",
        "systemctl start qemu-guest-agent",
      ]
    })
  }
}

