terraform {
  required_providers {
    azurerm = {
      source = "hashicorp/azurerm"
    }
    random = {
      source = "hashicorp/random"
    }
  }
}

resource "azurerm_resource_group" "rg" {
  name     = "rg-eus-dev-hub"
  location = "eastus"
  tags = {
    Environment = "Development"
  }
}

resource "azurerm_virtual_network" "vnet" {
  name                = "vnet-eus-dev-hub"
  location            = azurerm_resource_group.rg.location
  resource_group_name = azurerm_resource_group.rg.name
  address_space       = ["10.1.0.0/20"]
}