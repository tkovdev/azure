module "hub_dev" {
  source         = "../../modules/vnet"
  name           = "vnet-eus-dev-hub"
  location       = "eastus"
  resource_group = "rg-eus-dev-hub" 
  address_space  = ["10.1.0.0/20"]
  subnets = {
    GatewaySubnet = "10.1.0.0/26"
    CaddyReverseProxy = "10.1.0.64/28"
  }
  tags = {
    "Environment" = "Development"
  }
}

locals {
  vm_admin_username_caddyreverseproxy = "vmeusdcaddyreverseproxy"
}

resource "azurerm_public_ip" "vm_pip" {
  name                = "pip-${local.vm_admin_username_caddyreverseproxy}"
  location            = module.hub_dev.location
  resource_group_name = module.hub_dev.resource_group_name
  allocation_method   = "Static"
  sku                 = "Standard"
}

resource "azurerm_network_interface" "vm_nic" {
  name                = "nic-${local.vm_admin_username_caddyreverseproxy}"
  location            = module.hub_dev.location
  resource_group_name = module.hub_dev.resource_group_name

  ip_configuration {
    name                          = "ipconfig1"
    subnet_id                     = module.hub_dev.subnet_ids["CaddyReverseProxy"]
    private_ip_address_allocation = "Dynamic"
    public_ip_address_id          = azurerm_public_ip.vm_pip.id
  }
}

module "caddy_reverse_proxy" {
  source         = "../../modules/vm"
  name           = local.vm_admin_username_caddyreverseproxy
  location       = module.hub_dev.location
  resource_group = module.hub_dev.resource_group_name
  vm_admin_username = var.vm_admin_username_caddyreverseproxy
  vm_admin_password = var.vm_admin_password_caddyreverseproxy
  subnet = module.hub_dev.subnet_ids["CaddyReverseProxy"]
  external_nic_id = azurerm_network_interface.vm_nic.id
  tags = {
    "Environment" = "Development"
  }
}


