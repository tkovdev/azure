output "vm_private_ip_address" {
	value = module.vm.private_ip_address
}

output "vnet_id" {
	value = module.vnet.vnet_id
}

output "vnet_name" {
	value = module.vnet.vnet_name
}

output "vnet_resource_group_name" {
	value = module.vnet.resource_group_name
}
