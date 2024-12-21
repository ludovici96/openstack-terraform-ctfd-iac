resource "openstack_networking_network_v2" "group_21_network" {
  name           = "Group_21_Network"
  admin_state_up = true
}

resource "openstack_networking_subnet_v2" "group_21_subnet" {
  name            = "group_21_Subnet"
  network_id      = openstack_networking_network_v2.group_21_network.id
  cidr            = "192.168.1.0/24"
  ip_version      = 4
  gateway_ip      = "192.168.1.1"
  dns_nameservers = ["158.37.218.20", "158.37.218.21", "158.37.242.20", "158.37.242.21", "128.39.54.10"]
}

resource "openstack_networking_router_v2" "group_21_router" {
  name                = "group_21_Router"
  admin_state_up      = true
  external_network_id = var.external_network_id
}

resource "openstack_networking_router_interface_v2" "group_21_router_iface" {
  router_id = openstack_networking_router_v2.group_21_router.id
  subnet_id = openstack_networking_subnet_v2.group_21_subnet.id
}

resource "openstack_networking_secgroup_v2" "backend_sg_group_21" {
  name        = "backend_sg_group_21"
  description = "Security group for Redis and MariaDB, accessible only by CTFd"
}

resource "openstack_networking_secgroup_rule_v2" "redis_rule" {
  direction         = "ingress"
  ethertype         = "IPv4"
  protocol          = "tcp"
  port_range_min    = 6379
  port_range_max    = 6379
  remote_ip_prefix  = "192.168.1.0/24"
  security_group_id = openstack_networking_secgroup_v2.backend_sg_group_21.id
}

resource "openstack_networking_secgroup_rule_v2" "mariadb_rule" {
  direction         = "ingress"
  ethertype         = "IPv4"
  protocol          = "tcp"
  port_range_min    = 3306
  port_range_max    = 3306
  remote_ip_prefix  = "192.168.1.0/24"
  security_group_id = openstack_networking_secgroup_v2.backend_sg_group_21.id
}

resource "openstack_networking_secgroup_v2" "nginx_sg_group_21" {
  name        = "nginx_sg_group_21"
  description = "Security group for Nginx, accessible from the Internet on port 80"
}

resource "openstack_networking_secgroup_rule_v2" "nginx_http_rule" {
  direction         = "ingress"
  ethertype         = "IPv4"
  protocol          = "tcp"
  port_range_min    = 80
  port_range_max    = 80
  remote_ip_prefix  = "0.0.0.0/0"
  security_group_id = openstack_networking_secgroup_v2.nginx_sg_group_21.id
}

resource "openstack_networking_secgroup_v2" "ctfd_sg_group_21" {
  name        = "ctfd_sg_group_21"
  description = "Security group for CTFd instance"
}

resource "openstack_networking_secgroup_rule_v2" "ctfd_inbound_http" {
  direction         = "ingress"
  ethertype         = "IPv4"
  protocol          = "tcp"
  port_range_min    = 8000
  port_range_max    = 8000
  remote_ip_prefix  = "0.0.0.0/0"
  security_group_id = openstack_networking_secgroup_v2.ctfd_sg_group_21.id
}

resource "openstack_networking_secgroup_rule_v2" "ctfd_outbound_tcp" {
  direction         = "egress"
  ethertype         = "IPv4"
  protocol          = "tcp"
  port_range_min    = 65535
  port_range_max    = 65535
  remote_ip_prefix  = "0.0.0.0/0"
  security_group_id = openstack_networking_secgroup_v2.ctfd_sg_group_21.id
}

# Security group for ICMP to ping the instances
resource "openstack_networking_secgroup_v2" "group_21_secgroup_rule_icmp" {
  name        = "group_21_secgroup_rule_icmp"
  description = "Security group for ICMP to ping the instances"
}

resource "openstack_networking_secgroup_rule_v2" "group_21_secgroup_rule_icmp" {
  direction         = "ingress"
  ethertype         = "IPv4"
  protocol          = "icmp"
  remote_ip_prefix  = "0.0.0.0/0"
  security_group_id = openstack_networking_secgroup_v2.group_21_secgroup_rule_icmp.id
}


resource "openstack_networking_secgroup_v2" "group_21_secgroup_rule_ssh" {
  name        = "group_21_secgroup_rule_ssh"
  description = "Security group to ssh into the instances"
}

resource "openstack_networking_secgroup_rule_v2" "group_21_secgroup_rule_ssh" {
  direction         = "ingress"
  ethertype         = "IPv4"
  protocol          = "tcp"
  port_range_min    = 22
  port_range_max    = 22
  remote_ip_prefix  = "0.0.0.0/0"
  security_group_id = openstack_networking_secgroup_v2.group_21_secgroup_rule_ssh.id
}


