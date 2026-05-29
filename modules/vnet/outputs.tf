# modules/vnet/outputs.tf

output "vnet_id" {
  value = azurerm_virtual_network.this.id
}

output "vnet_name" {
  value = azurerm_virtual_network.this.name
}

output "resource_group_name" {
  value = azurerm_resource_group.this.name
}