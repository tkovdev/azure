## AZURE ##
variable "azure_client_id" {
  type      = string
}

variable "azure_client_secret" {
  type      = string
  sensitive = true
}

variable "azure_subscription_id" {
  type      = string
}

variable "azure_tenant_id" {
  type      = string
}

## Resource Vars ##
variable "vm_admin_username" {
  type    = string
  default = "azureuser"
}

variable "vm_admin_password" {
  type      = string
  sensitive = true
}