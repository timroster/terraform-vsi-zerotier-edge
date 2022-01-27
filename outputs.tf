output ids {
  description = "The instance id"
  value       = ibm_is_instance.vsi[*].id
}

output names {
  description = "The instance names"
  value       = ibm_is_instance.vsi[*].name
}

output vpc_name {
  value = data.ibm_is_vpc.vpc.name
}

output count {
  value = var.vpc_subnet_count
}

output instance_count {
  value = var.vpc_subnet_count
}

output public_ips {
  value       = var.create_public_ip ? ibm_is_floating_ip.vsi[*].address : []
}

output private_ips {
  value = ibm_is_instance.vsi[*].primary_network_interface[0].primary_ipv4_address
}

output network_interface_ids {
   value = ibm_is_instance.vsi[*].primary_network_interface[0].id
}

output "security_group_id" {
  description = "The id of the security group that was created"
  value       = ibm_is_security_group.vsi.id
}

output "security_group" {
  description = "The security group that was created"
  value       = ibm_is_security_group.vsi
}

output "maintenance_security_group_id" {
  description = "The id of the security group that was used"
  value       = local.base_security_group
}

output "zerotier_network_cidr" {
  description = "LAN for zerotier"
  value       = local.zt_network_cidr
}