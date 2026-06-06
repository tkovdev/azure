resource "azurerm_network_security_group" "vm_nsg" {
  name                = "nsg-${var.name}"
  location            = var.location
  resource_group_name = var.resource_group

  security_rule {
    name                       = "allow-ssh"
    priority                   = 100
    direction                  = "Inbound"
    access                     = "Allow"
    protocol                   = "Tcp"
    source_port_range          = "*"
    destination_port_range     = "22"
    source_address_prefix      = "*"
    destination_address_prefix = "*"
  }


  security_rule {
    name                       = "allow-http"
    priority                   = 130
    direction                  = "Inbound"
    access                     = "Allow"
    protocol                   = "Tcp"
    source_port_range          = "*"
    destination_port_range     = "80"
    source_address_prefix      = "*"
    destination_address_prefix = "*"
  }

  security_rule {
    name                       = "allow-https"
    priority                   = 140
    direction                  = "Inbound"
    access                     = "Allow"
    protocol                   = "Tcp"
    source_port_range          = "*"
    destination_port_range     = "443"
    source_address_prefix      = "*"
    destination_address_prefix = "*"
  }
}

# either use the externally provided nic or use the one created in this tf
locals {
  effective_nic_id = var.use_alternative_nic ? one(azurerm_network_interface.vm_nic[*].id) : var.external_nic_id
}

resource "azurerm_network_interface" "vm_nic" {
  # Create an internal NIC only when explicitly using the module-managed path.
  count = var.use_alternative_nic ? 1 : 0
  name                = "nic-${var.name}"
  location            = var.location
  resource_group_name = var.resource_group

  ip_configuration {
    name                          = "ipconfig1"
    subnet_id                     = var.subnet
    private_ip_address_allocation = "Dynamic"
    public_ip_address_id          = null
  }
}

resource "azurerm_network_interface_security_group_association" "vm_assoc" {
  network_interface_id      = local.effective_nic_id
  network_security_group_id = azurerm_network_security_group.vm_nsg.id
}

resource "azurerm_linux_virtual_machine" "vm" {
  name                = "vm-${var.name}"
  resource_group_name = var.resource_group
  location            = var.location
  size                = var.vm_size
  admin_username      = var.vm_admin_username
  admin_password      = var.vm_admin_password
  network_interface_ids = [
    local.effective_nic_id
  ]

  disable_password_authentication = false

  os_disk {
    caching              = "ReadWrite"
    storage_account_type = "Standard_LRS"
  }

  source_image_reference {
    publisher = "Canonical"
    offer     = "0001-com-ubuntu-server-jammy"
    sku       = "22_04-lts"
    version   = "latest"
  }

  tags = var.tags
}