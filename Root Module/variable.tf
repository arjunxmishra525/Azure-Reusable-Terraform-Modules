variable "RG" {

  validation {
    condition = alltrue([
      for arjun in values(var.RG) :
      contains(
        ["dev-rg", "qa-rg", "prod-rg"],
        lower(trimspace(arjun.name))
      )
    ])
    error_message = "RG name must be dev-rg, qa-rg, or prod-rg."
  }
}

variable "vnet" {
  type = map(object({
    name = string
    resource_group_name = string
    location = string
    address_space = list(string)
  }))
validation {
    condition = alltrue([
      for arjun in values(var.vnet) :
      length(arjun.address_space) == 1 &&
      arjun.address_space[0] == "10.20.0.0/16"
    ])
    error_message = "Address space must be 10.20.0.0/16 "
  }
}

variable "azurerm_subnet" {
  type = map(object({
    name = string
    resource_group_name = string
    virtual_network_name = string
    address_prefixes = list(string)
  }))
}


variable "bastion" {
type = map(any)
}

variable "nic" {
  type = map(object({
    name = string
    location = string
    resource_group_name =string
    private_ip_address_allocation = string
    name_ip_config = string
    virtual_network_name = string
    data_subnet = string

  }))
}