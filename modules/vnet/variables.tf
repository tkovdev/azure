
variable "name" {
  type = string
}

variable "resource_group" {
  type = string
}

variable "location" {
  type = string
}

variable "address_space" {
  type = list(string)
}

variable "subnets" {
  type = map(string)  # name → cidr
}

variable "tags" {
  type = map(string)
}