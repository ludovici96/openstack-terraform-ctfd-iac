output "network_id" {
  value = openstack_networking_network_v2.group_21_network.id
  description = "The ID of the network created."
}

output "subnet_id" {
  value = openstack_networking_subnet_v2.group_21_subnet.id
  description = "The ID of the subnet created."
}

output "router_id" {
  value = openstack_networking_router_v2.group_21_router.id
  description = "The ID of the router created."
}

output "backend_sg_group_21_id" {
  value = openstack_networking_secgroup_v2.backend_sg_group_21.id
  description = "Security Group ID for Backend"
}

output "nginx_sg_group_21_id" {
  value = openstack_networking_secgroup_v2.nginx_sg_group_21.id
  description = "Security Group ID for Nginx"
}

output "ctfd_sg_group_21_id" {
  value = openstack_networking_secgroup_v2.ctfd_sg_group_21.id
  description = "Security Group ID for CTFd"
}

output "group_21_secgroup_rule_icmp" {
  value = openstack_networking_secgroup_v2.group_21_secgroup_rule_icmp.id
  description = "Security Group ID for ICMP to ping the instances"
}

output "group_21_secgroup_rule_ssh" {
  value = openstack_networking_secgroup_v2.group_21_secgroup_rule_ssh.id
  description = "Security group to ssh into the instances"
}
