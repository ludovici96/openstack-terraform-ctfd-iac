# security groups for the intances to open ports etc.
variable "backend_sg_group_21_id" {}
variable "nginx_sg_group_21_id" {}
variable "ctfd_sg_group_21_id" {}
variable "group_21_secgroup_rule_icmp" {}
variable "group_21_secgroup_rule_ssh" {}

# varibales to create the intances
variable "instances" {
  type = list(object({
    name        : string
    image_id    : string
    flavor_id   : string
    network_id  : string
    security_groups : list(string)
  }))
  description = "List of instance configurations"
}

# cloud init insertion variable
variable "user_data" {
  type        = string
  description = "User data for cloud-init configuration"
}