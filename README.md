# Homelab Infrastructure as Code

This repository contains the complete Infrastructure as Code (IaC) configuration for my homelab, built with Terraform and Terragrunt. It manages everything from VM provisioning on Proxmox to containerized application deployments via Portainer.

## 🏗️ Architecture Overview

The homelab is organized into three main layers:

1. **Infrastructure Layer** (`live/infra/`) - Proxmox VMs and base infrastructure
2. **Container Layer** (`live/docker/`) - Docker networks, images, and services
3. **Application Layer** (`live/portainer/`) - Self-hosted applications running in Docker Swarm

## 🛠️ Technology Stack

- **Infrastructure Orchestration**: [Terragrunt](https://terragrunt.gruntwork.io/)
- **Infrastructure Provisioning**: [Terraform](https://www.terraform.io/)
- **Virtualization Platform**: [Proxmox VE](https://www.proxmox.com/)
- **Container Management**: [Portainer](https://www.portainer.io/) (Docker Swarm mode)
- **Secrets Management**: [SOPS](https://github.com/getsops/sops) with age encryption
- **State Storage**: S3-compatible backend

### Terraform Providers

- [bpg/proxmox](https://registry.terraform.io/providers/bpg/proxmox) - Proxmox infrastructure management
- [portainer/portainer](https://registry.terraform.io/providers/portainer/portainer) - Container stack deployment
- [kreuzwerker/docker](https://registry.terraform.io/providers/kreuzwerker/docker) - Docker resources
- [goauthentik/authentik](https://registry.terraform.io/providers/goauthentik/authentik) - SSO/Identity management

## ⚙️ Configuration Management

The homelab uses centralized configuration modules to ensure consistency across all services:

### DNS/FQDN Configuration (`live/config/dns/`)

All service domain names are centrally managed in the DNS configuration module. This provides:

- **Single Source of Truth**: All FQDNs are defined in one place (`live/config/dns/terragrunt.hcl`)
- **Consistency**: Services reference domain names via variables instead of hardcoded literals
- **Easy Updates**: Change domain names once, propagate everywhere automatically
- **Type Safety**: Terraform validates FQDN usage across all modules

Services access DNS configuration through the `dns_config` variable:
```hcl
dns_config = {
  zone     = "denyssizomin.com"
  services = {
    auth      = "auth.denyssizomin.com"
    pulse     = "pulse.denyssizomin.com"
    paperless = "paperless.denyssizomin.com"
    gist      = "gist.denyssizomin.com"
    # ... other services
  }
  email = "admin@denyssizomin.com"
}
```

### OIDC Configuration (`live/config/oidc/`)

Centralized OIDC provider client IDs for Authentik SSO integration.

## 📁 Repository Structure

```
.
├── live/                          # Live environment configurations
│   ├── root.hcl                   # Root Terragrunt config with S3 backend
│   ├── config/                    # Configuration management
│   │   ├── dns/                   # Centralized DNS/FQDN configuration
│   │   └── oidc/                  # OIDC provider configurations
│   ├── infra/                     # Infrastructure layer
│   │   ├── providers.hcl          # Proxmox provider configuration
│   │   └── vms/                   # Virtual machine definitions
│   │       ├── docker-apps/       # VM for Docker applications
│   │       ├── homeassistant/     # Home Assistant VM
│   │       └── workbench/         # Development workbench VM
│   ├── docker/                    # Docker infrastructure
│   │   ├── networks/              # Docker networks
│   │   │   └── proxy/             # Reverse proxy network
│   │   ├── images/                # Custom Docker images
│   │   │   └── caddy/             # Custom Caddy image
│   │   └── services/              # Docker services
│   │       └── portainer/         # Portainer service
│   └── portainer/                 # Application deployments
│       ├── providers.hcl          # Portainer provider configuration
│       ├── admin/                 # Portainer admin settings
│       ├── settings/              # Global stack settings
│       ├── authentik/             # SSO & Identity Provider
│       ├── caddy/                 # Reverse proxy & TLS termination
│       ├── ddns/                  # Dynamic DNS updater
│       ├── miniserve/             # Simple file server
│       ├── opengist/              # Code snippet sharing
│       ├── paperless/             # Document management system
│       └── pulse/                 # System monitoring
├── modules/                       # Reusable Terraform modules
│   ├── authentik/                 # Authentik configuration modules
│   │   └── oidc_provider/         # OIDC provider module
│   ├── config/                    # Configuration modules
│   │   ├── dns/                   # DNS configuration module
│   │   └── oidc/                  # OIDC configuration
│   ├── docker/                    # Docker resource modules
│   ├── infra/                     # Infrastructure modules
│   │   ├── cloud-init/            # Cloud-init configuration
│   │   └── vms/                   # VM templates
│   │       ├── debian-vm/         # Debian VM module
│   │       └── hass-vm/           # Home Assistant VM module
│   └── portainer/                 # Application stack modules
│       ├── admin/                 # Admin configuration
│       ├── authentik/             # Authentik stack
│       ├── caddy/                 # Caddy reverse proxy
│       ├── ddns/                  # DDNS client
│       ├── miniserve/             # File server
│       ├── opengist/              # Gist platform
│       ├── paperless/             # Document management
│       ├── pulse/                 # Monitoring
│       └── settings/              # Stack settings
├── .sops.yaml                     # SOPS encryption configuration
└── sops.env                       # Encrypted environment variables
```

## 🚀 Getting Started

### Prerequisites

Ensure you have the following tools installed:

- [Terraform](https://www.terraform.io/downloads) (>= 1.6)
- [Terragrunt](https://terragrunt.gruntwork.io/docs/getting-started/install/) (>= 0.50)
- [SOPS](https://github.com/getsops/sops) (for secrets management)
- [age](https://github.com/FiloSottile/age) (for SOPS encryption)
- SSH key pair for Proxmox access (`~/.ssh/homelab`)

### Environment Setup

1. **Clone the repository**:
   ```bash
   git clone <repository-url>
   cd homelab-iac
   ```

2. **Configure secrets**:

   Create/update `sops.env` with required credentials:
   ```bash
   # Decrypt (if exists)
   sops sops.env

   # Add required variables:
   # - PROXMOX_ENDPOINT
   # - PROXMOX_API_TOKEN
   # - PORTAINER_API_KEY
   # - S3 backend credentials (if using)
   ```

3. **Source environment variables**:
   ```bash
   source <(sops -d sops.env)
   ```

4. **Initialize the infrastructure**:
   ```bash
   # From the project root
   cd live/infra/vms/docker-apps
   terragrunt init
   ```

## 🔧 Usage

### Managing Infrastructure

**Deploy a specific module**:
```bash
cd live/portainer/authentik
terragrunt apply
```

**Deploy all modules in a directory**:
```bash
cd live/portainer
terragrunt run-all apply
```

**Plan changes before applying**:
```bash
terragrunt plan
```

**Destroy resources**:
```bash
terragrunt destroy
```

### Working with SOPS

**Encrypt a new file**:
```bash
sops -e file.yaml > encrypted.yaml
```

**Edit encrypted file**:
```bash
sops file.yaml
```

**Decrypt and view**:
```bash
sops -d file.yaml
```

### Dependency Graph

The infrastructure follows this deployment order:

1. **Proxmox VMs** (`live/infra/vms/*`)
2. **Docker Infrastructure** (`live/docker/*`)
3. **Portainer Service** (`live/docker/services/portainer`)
4. **Application Stacks** (`live/portainer/*`)

Terragrunt automatically handles dependencies between modules using `dependency` blocks.

## 📦 Deployed Applications

| Application | Description | Module Path |
|-------------|-------------|-------------|
| **Authentik** | Identity Provider & SSO | `portainer/authentik` |
| **Caddy** | Reverse Proxy & TLS | `portainer/caddy` |
| **Paperless-ngx** | Document Management | `portainer/paperless` |
| **OpenGist** | Code Snippet Sharing | `portainer/opengist` |
| **Miniserve** | Simple File Server | `portainer/miniserve` |
| **Pulse** | System Monitoring | `portainer/pulse` |
| **DDNS** | Dynamic DNS Client | `portainer/ddns` |
| **Home Assistant** | Home Automation | `infra/vms/homeassistant` |

## 🔐 Security

- **Secrets Management**: All sensitive data is encrypted using SOPS with age encryption
- **API Keys**: Stored in encrypted `sops.env` and passed via environment variables
- **SSH Keys**: Used for Proxmox authentication (`~/.ssh/homelab`)
- **State Backend**: Terraform state is stored remotely in S3-compatible storage
- **TLS**: Caddy handles automatic certificate provisioning and renewal

### Age Key Management

Your age public key is configured in `.sops.yaml`. Keep your private age key secure:
```bash
# Default location
~/.config/sops/age/keys.txt
```

## 🏃 Continuous Deployment

This setup is designed for GitOps-style deployments:

1. Make changes to configuration files
2. Commit and push to version control
3. Run `terragrunt apply` in the relevant directory
4. Changes are automatically propagated to the infrastructure

## 📝 License

This project is provided as-is for educational and personal use.

## 🔗 Resources

- [Terragrunt Documentation](https://terragrunt.gruntwork.io/docs/)
- [Terraform Registry](https://registry.terraform.io/)
- [Proxmox Provider Docs](https://registry.terraform.io/providers/bpg/proxmox/latest/docs)
- [Portainer Provider Docs](https://registry.terraform.io/providers/portainer/portainer/latest/docs)
- [SOPS Documentation](https://github.com/getsops/sops)
