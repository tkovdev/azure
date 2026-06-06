output "pip_id_address" {
    value = azurerm_public_ip.vm_pip.ip_address
}

output "ansible_inventory_file" {
    value = local_sensitive_file.ansible_inventory.filename
}