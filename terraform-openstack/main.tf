terraform {
  required_version = ">= 0.14.0"

  required_providers {
    openstack = {
      source  = "terraform-provider-openstack/openstack"
      version = "~> 1.53.0"
    }
  }
}

# Configure the OpenStack Provider
provider "openstack" {
  user_name   = var.OS_USERNAME
  tenant_name = var.OS_PROJECT_NAME
  password    = var.OS_PASSWORD
  auth_url    = var.OS_AUTH_URL
  domain_name = var.OS_USER_DOMAIN_NAME
}

module "network" {
  source = "./modules/network"
  providers = {
  openstack = openstack
  }

  external_network_id = var.external_network_id
}

module "compute" {
  depends_on = [module.network]
  source = "./modules/compute"
  providers = {
    openstack = openstack
  }


  # Cloud-init configuration
  user_data = file("${path.module}/cloud-init.yml")

  # security groups
  backend_sg_group_21_id = module.network.backend_sg_group_21_id
  nginx_sg_group_21_id   = module.network.nginx_sg_group_21_id
  ctfd_sg_group_21_id    = module.network.ctfd_sg_group_21_id
  group_21_secgroup_rule_icmp = module.network.group_21_secgroup_rule_icmp
  group_21_secgroup_rule_ssh  = module.network.group_21_secgroup_rule_ssh

  instances       = [
    {
      name       = "Redis_Instance"
      image_id   = var.image_id
      flavor_id  = var.small_flavor_id
      network_id = module.network.network_id
      security_groups = [
      module.network.backend_sg_group_21_id,
      module.network.group_21_secgroup_rule_icmp, 
      module.network.group_21_secgroup_rule_ssh
      ]
    }, 
    {
      name       = "db_Instance"
      image_id   = var.image_id
      flavor_id  = var.small_flavor_id
      network_id = module.network.network_id
      security_groups  = [
      module.network.backend_sg_group_21_id,
      module.network.group_21_secgroup_rule_icmp,
      module.network.group_21_secgroup_rule_ssh
      ]
    },
    {
      name       = "ctfd_Instance"
      image_id   = var.image_id
      flavor_id  = var.medium_flavor_id
      network_id = module.network.network_id
      security_groups  = [
      module.network.ctfd_sg_group_21_id,
      module.network.group_21_secgroup_rule_icmp,
      module.network.group_21_secgroup_rule_ssh
      ]
    },
    {
      name       = "Nginx_Instance"
      image_id   = var.image_id
      flavor_id  = var.medium_flavor_id
      network_id = module.network.network_id
      security_groups  = [
      module.network.nginx_sg_group_21_id,
      module.network.group_21_secgroup_rule_icmp,
      module.network.group_21_secgroup_rule_ssh
      ] 
    }
  ]
}

# to update the "terraform-openstack/ansible/inventory/staging.yml" file with correct IP addresses
data "template_file" "ansible_inventory" {
  template = file("${path.module}/templates/inventory.tpl")

  vars = {
    redis_ip  = module.compute.instance_floating_ips["Redis_Instance"]
    db_ip     = module.compute.instance_floating_ips["db_Instance"]
    ctfd_ip   = module.compute.instance_floating_ips["ctfd_Instance"]
    nginx_ip  = module.compute.instance_floating_ips["Nginx_Instance"]
  }
}

resource "local_file" "ansible_inventory_file" {
  content  = data.template_file.ansible_inventory.rendered
  filename = "${path.module}/ansible/inventory/staging.yml"
}

# to update the "terraform-openstack/ansible/group_vars/all/vars.yml" file with correct IP addresses
data "template_file" "ansible_vars" {
  depends_on = [ module.compute, module.network ]
  template = file("${path.module}/templates/vars.tpl")

  vars = {
    redis_internal_ip = module.compute.instance_internal_ips["Redis_Instance"]
    db_internal_ip    = module.compute.instance_internal_ips["db_Instance"]
    ctfd_internal_ip  = module.compute.instance_internal_ips["ctfd_Instance"]
  }
}

resource "local_file" "ansible_vars_file" {
  depends_on = [ module.compute, module.network ]
  content  = data.template_file.ansible_vars.rendered
  filename = "${path.module}/ansible/group_vars/all/vars.yml"
}

# Provisioning the instances using Ansible. tried to use "ansible/ansible" provider but it didnt work as i wanted
resource "null_resource" "ansible_provisioning" {
  # Ensures that Ansible runs after all instances are available
  depends_on = [module.compute, local_file.ansible_inventory_file, local_file.ansible_vars_file]

  triggers = {
    # This will re-run the playbook if the IP addresses change
    always_run = join(",", values(module.compute.instance_floating_ips))
  }

  provisioner "local-exec" {
    command = <<EOF
      sleep 30; # waits 30 seconds before executing the ansible playbook to give time for the instances to boot up fully
      ANSIBLE_HOST_KEY_CHECKING=False ansible-playbook -i ./ansible/inventory/staging.yml ./ansible/playbook.yml --user=ubuntu --private-key=./ansible/id_ed25519
    EOF

    environment = {
      ANSIBLE_STDOUT_CALLBACK = "debug"
    }
  }
}
