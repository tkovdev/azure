output "vm_id" {
    value = azurerm_linux_virtual_machine.vm.id
}

output "vm_admin_username" {
    value = azurerm_linux_virtual_machine.vm.admin_username
}

output "private_ip_address" {
    value = try(azurerm_network_interface.vm_nic[0].private_ip_address, null)
}