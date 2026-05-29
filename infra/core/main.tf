module "hub_dev" {
  source         = "../../modules/vnet"
  name           = "vnet-eus-dev-hub"
  address_space  = ["10.1.0.0/20"]
  resource_group = "rg-eus-dev-hub" 
  location       = "eastus"
  subnets = {
    GatewaySubnet = "10.1.0.0/26"
  }
  tags = {
    "Environment" = "Development"
  }
}


