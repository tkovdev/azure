data "terraform_remote_state" "dockerengine" {
  backend = "local"

  config = {
    path = "${path.module}/../spokes/rg-eus-dev-dockerengine/terraform.tfstate"
  }
}

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

resource "local_sensitive_file" "ansible_inventory" {
  filename = "${path.module}/../../ansible/inventory/terraform_hosts.ini"
  content  = <<-EOT
    [caddy]
    caddy-vm ansible_host=${azurerm_public_ip.vm_pip.ip_address}

    [caddy:vars]
    ansible_user=${module.caddy_reverse_proxy.vm_admin_username}
    ansible_password=${var.vm_admin_password_caddyreverseproxy}
    ansible_become=true
    ansible_become_method=sudo
    ansible_become_password=${var.vm_admin_password_caddyreverseproxy}
    ansible_connection=ssh
    ansible_ssh_common_args='-o StrictHostKeyChecking=no'
  EOT

  file_permission = "0600"
}

resource "local_file" "ansible_caddy_generated_vars" {
  filename = "${path.module}/../../ansible/group_vars/caddy.generated.yml"
  content  = <<-EOT
    caddy_upstream_host: ${data.terraform_remote_state.dockerengine.outputs.vm_private_ip_address}
  EOT

  file_permission = "0644"
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
  use_alternative_nic = false
  subnet = module.hub_dev.subnet_ids["CaddyReverseProxy"]
  external_nic_id = azurerm_network_interface.vm_nic.id
  tags = {
    "Environment" = "Development"
  }
}

resource "azurerm_virtual_network_peering" "hub_to_dockerengine" {
  name                      = "peer-vnet-eus-dev-hub-to-dockerengine"
  resource_group_name       = module.hub_dev.resource_group_name
  virtual_network_name      = module.hub_dev.vnet_name
  remote_virtual_network_id = data.terraform_remote_state.dockerengine.outputs.vnet_id
}

resource "azurerm_virtual_network_peering" "dockerengine_to_hub" {
  name                      = "peer-vnet-eus-dev-dockerengine-to-hub"
  resource_group_name       = data.terraform_remote_state.dockerengine.outputs.vnet_resource_group_name
  virtual_network_name      = data.terraform_remote_state.dockerengine.outputs.vnet_name
  remote_virtual_network_id = module.hub_dev.vnet_id
}

resource "null_resource" "configure_caddy" {
  triggers = {
    vm_id                  = module.caddy_reverse_proxy.vm_id
    public_ip              = azurerm_public_ip.vm_pip.ip_address
    upstream_host          = data.terraform_remote_state.dockerengine.outputs.vm_private_ip_address
    inventory_hash         = sha256(local_sensitive_file.ansible_inventory.content)
    playbook_hash          = filesha256("${path.module}/../../ansible/playbooks/caddy_reverse_proxy.yml")
    caddy_template_hash    = filesha256("${path.module}/../../ansible/templates/Caddyfile.j2")
    caddy_group_vars_hash  = filesha256("${path.module}/../../ansible/group_vars/caddy.yml")
    caddy_generated_hash   = sha256(local_file.ansible_caddy_generated_vars.content)
  }

  provisioner "local-exec" {
    working_dir = "${path.module}/../.."
    command     = "ansible-playbook -i ansible/inventory/terraform_hosts.ini ansible/playbooks/caddy_reverse_proxy.yml"

    environment = {
      ANSIBLE_HOST_KEY_CHECKING = "False"
    }
  }

  depends_on = [
    module.caddy_reverse_proxy,
    local_sensitive_file.ansible_inventory,
    local_file.ansible_caddy_generated_vars,
    azurerm_virtual_network_peering.hub_to_dockerengine,
    azurerm_virtual_network_peering.dockerengine_to_hub,
  ]
}


