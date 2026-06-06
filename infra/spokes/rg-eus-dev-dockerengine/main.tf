module "vnet" {
  source         = "../../../modules/vnet"
  name           = "vnet-eus-dev-dockerengine"
  address_space  = ["10.3.0.0/27"]
  resource_group = "rg-eus-dev-dockerengine" 
  location       = "eastus"
  subnets = {
    VM = "10.3.0.0/28"
  }
  tags = {
    "Environment" = "Development"
  }
}

module "vm" {
  source         = "../../../modules/vm"
  name           = "vm-eus-dev-dockerengine"
  vm_admin_username = var.vm_admin_username
  vm_admin_password = var.vm_admin_password
  resource_group = module.vnet.resource_group_name
  subnet = module.vnet.subnet_ids["VM"]
  location = "eastus"
  tags = {
    "Environment" = "Development"
  }
}