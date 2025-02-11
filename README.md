# IMPORTANT

Please update the file `cloud-init.yml` with your github username
```
# Import SSH keys from your GitHub
users:
  - name: ubuntu
    shell: /bin/bash
    groups: [sudo]
    sudo: ALL=(ALL) NOPASSWD:ALL
    ssh_import_id:
      - gh: YOUR_GITHUB_USERNAME
    lock_passwd: true
```

Also update the `terraform.tfvars` file with your openstack credentials so that terraform can create the virtual machines.

```
OS_USERNAME="openstack username"
OS_PROJECT_NAME="openstack project name"
OS_PASSWORD="openstack passwords"
OS_USER_DOMAIN_NAME="Default"
OS_PROJECT_DOMAIN_NAME="Default"
OS_AUTH_URL="http:// url here :5000/v3"
OS_IDENTITY_API_VERSION="3"
external_network_id="external network id here"
small_flavor_id="flavor id if you have"
medium_flavor_id="flavor id if you have"
image_id="image id if you have"
```

# Infrastructure As Code - CTFd Platform Deployment

This project implements Infrastructure as Code (IaC) to automatically deploy a CTFd platform with supporting services on OpenStack. It uses Terraform for infrastructure provisioning and Ansible for configuration management.

## Architecture

The deployment creates a distributed system with four specialized instances:
- **Redis Instance**: Handles caching and session management
- **MariaDB Instance**: Provides persistent data storage
- **CTFd Instance**: Runs the main CTFd application
- **Nginx Instance**: Acts as a reverse proxy and load balancer

### Service Configuration

#### Database (MariaDB)
- Configured for remote access
- Dedicated CTFd database and user
- Secure installation with root password
- Listens on all network interfaces (0.0.0.0)

#### Cache (Redis)
- Custom interface binding
- Systemd managed service
- Optimized for CTFd caching requirements

#### Application (CTFd)
- Latest version from official GitHub repository
- Custom environment configuration
- Runs as a systemd service
- Python dependencies managed via pip
- Built with required development tools

#### Reverse Proxy (Nginx)
- Custom configuration for CTFd
- SSL/TLS ready (configuration required)
- Removes default site configuration
- Managed through systemd

## Prerequisites

- Terraform >= 0.14.0
- Ansible
- OpenStack credentials and access
- SSH key pair (to be placed in ./terraform-openstack/ansible/id_ed25519)
- GitHub account for SSH key import
- Basic understanding of OpenStack concepts
- Properly configured OpenStack environment variables

## Project Structure

```
.
├── terraform-openstack/
│   ├── ansible/         # Ansible playbooks and configuration
│   ├── modules/        # Terraform modules
│   │   ├── compute/    # Instance creation
│   │   └── network/    # Network infrastructure
│   ├── templates/      # Configuration templates
│   ├── cloud-init.yml  # Cloud-init configuration
│   ├── main.tf        # Main Terraform configuration
│   ├── variables.tf    # Variable definitions
│   └── terraform.tfvars # Variable values
├── .cloudrc.example    # Example OpenStack RC file
├── vmcreator.sh       # Deployment script
└── README.md          # This file
```

## Security Groups

The infrastructure includes the following security groups:

- **Backend Security Group (Redis & MariaDB)**:
  - Internal access on port 6379 (Redis)
  - Internal access on port 3306 (MariaDB)
  - Limited to internal network communication

- **Nginx Security Group**:
  - Public access on port 80 (HTTP)
  - Public access on port 443 (HTTPS) - prepared for SSL/TLS
  - Acts as the main entry point for web traffic

- **CTFd Security Group**:
  - Internal access on port 8000 (CTFd application)
  - Communication restricted to Nginx proxy

- **Common Security Rules**:
  - SSH access on port 22 (configurable)
  - ICMP for network diagnostics
  - All instances include basic security measures

## Quick Start

1. Ensure your OpenStack credentials are correct in `terraform.tfvars`
2. Make the deployment script executable:
   ```bash
   chmod +x vmcreator.sh
   ```
3. Run the deployment script:
   ```bash
   ./vmcreator.sh
   ```
4. Choose from the menu options:
   - Create VMs
   - Destroy VMs
   - Display CTFd website IP
   - Exit

## Deployment Process

1. Terraform creates the network infrastructure
2. Instances are provisioned with floating IPs
3. Ansible inventory is automatically generated
4. Ansible playbooks configure the instances
5. The CTFd platform becomes accessible via Nginx

## Network Architecture

- Private network: 192.168.1.0/24
- Each instance gets both internal and floating IPs
- DNS servers are preconfigured
- Router connects to external network

## Maintenance

To destroy the infrastructure:
```bash
./vmcreator.sh
# Choose option 2
```

To get the CTFd website IP:
```bash
./vmcreator.sh
# Choose option 3
```

## Notes

- Instance flavors are predefined (small for backend, medium for frontend)
- Cloud-init is used for initial instance setup
- Ansible runs automatically after infrastructure creation
- There's a 30-second delay after instance creation to ensure full boot
