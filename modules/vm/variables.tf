
variable "resource_group" {
  type = string
}

variable "location" {
  type = string
}

variable "name" {
    type = string
}

variable "vm_admin_username" {
  type    = string
  default = "azureuser"
}

variable "vm_admin_password" {
  type      = string
  sensitive = true
}

variable "vm_size" {
  type    = string
  default = "Standard_B2ms"
}

variable "tags" {
  type = map(string)
}

variable "use_alternative_nic" {
  type = bool
  default = true

  validation {
    condition     = var.use_alternative_nic || var.external_nic_id != null
    error_message = "When use_alternative_nic is false, external_nic_id must be provided."
  }

  validation {
    condition     = !var.use_alternative_nic || var.subnet != null
    error_message = "When use_alternative_nic is true, subnet must be provided to create the internal NIC."
  }
}

variable "external_nic_id" {
  type = string
  default = null
  nullable = true
}

variable "subnet" {
  type = string
  nullable = true
}