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
- OpenStack credentials
- SSH key pair (placed in ./ansible/id_ed25519)
- GitHub account for SSH key import

## Project Structure

```
.
├── terraform-openstack/
│   ├── modules/
│   │   ├── compute/     # Instance creation
│   │   └── network/     # Network infrastructure
│   ├── ansible/         # Configuration management
│   ├── templates/       # Template files
│   ├── variables.tf     # Variable definitions
│   ├── terraform.tfvars # Variable values
│   └── main.tf         # Main Terraform configuration
└── vmcreator.sh        # Deployment script
```

## Security Groups

The infrastructure includes several security groups:
- Backend SG (Redis & MariaDB): Allows internal access on ports 6379 and 3306
- Nginx SG: Allows public access on port 80
- CTFd SG: Allows access on port 8000
- Common rules for SSH (port 22) and ICMP

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
