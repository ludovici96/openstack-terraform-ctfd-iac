# Outputs for Floating IPs
output "instance_floating_ips" {
  value = { for k, v in openstack_networking_floatingip_v2.fip : k => v.address }
  description = "Floating IP addresses of the instances"
}

# Outputs for Internal IPs
output "instance_internal_ips" {
  value = { for instance in openstack_compute_instance_v2.instance : instance.name => instance.network.0.fixed_ip_v4 }
  description = "Internal IP addresses of the instances"
}


#output "instance_ips" {
#  value = { for k, v in openstack_networking_floatingip_v2.fip : k => v.address }
#  description = "The IP addresses of the instances"
#}


