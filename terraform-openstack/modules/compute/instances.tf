resource "openstack_compute_instance_v2" "instance" {
  for_each = { for i in var.instances : i.name => i }

  name            = each.value.name
  image_id        = each.value.image_id
  flavor_id       = each.value.flavor_id
  security_groups = each.value.security_groups
  user_data       = var.user_data

  network {
    uuid = each.value.network_id
  }
}

resource "openstack_networking_floatingip_v2" "fip" {
  for_each = { for i in var.instances : i.name => i }
  pool     = "provider"
}

resource "openstack_compute_floatingip_associate_v2" "fip_associate" {
  for_each = { for i in var.instances : i.name => i }

  floating_ip = openstack_networking_floatingip_v2.fip[each.key].address
  instance_id = openstack_compute_instance_v2.instance[each.key].id
}