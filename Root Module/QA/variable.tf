variable "RG" {
  type = map(object({
    name     = string
    location = string
  }))
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
    name                = string
    resource_group_name = string
    location            = string
    address_space       = list(string)
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
    name                 = string
    resource_group_name  = string
    virtual_network_name = string
    address_prefixes     = list(string)
  }))
}


variable "bastion" {
  type = map(any)
}

variable "nic" {
  type = map(object({
    name                          = string
    location                      = string
    resource_group_name           = string
    private_ip_address_allocation = string
    name_ip_config                = string
    virtual_network_name          = string
    data_subnet                   = string

  }))
}


variable "nsg" {
  type = map(object({
    name                       = string
    location                   = string
    resource_group_name        = string
    name_rule                  = string
    protocol                   = string
    access                     = string
    direction                  = string
    priority                   = number
    source_port_range          = string
    destination_port_range     = string
    source_address_prefix      = string
    destination_address_prefix = string

  }))
}

variable "nsg_nic" {
  type = map(any)
}

variable "vm" {
  type = map(any)
}

variable "admin_username" {
  type = string
  # default = "arjunmishra"
}
variable "admin_password" {
  type      = string
  sensitive = true
  # default = "Arjunmishra@20"
}

variable "key_vault" {
  type = map(any)
}

variable "dns_zone" {
  type = map(object({
    name                = string
    resource_group_name = string
  }))
}


variable "dns_record" {
  description = "Configuration for Azure Public DNS A records."

  type = map(object({
    name                = string
    dns_zone_name       = string
    resource_group_name = string
    ttl                 = optional(number, 300)
    records             = list(string)
  }))

  validation {
    condition = alltrue([
      for record in values(var.dns_record) :
      record.ttl >= 30 && record.ttl <= 86400
    ])

    error_message = "DNS TTL must be between 30 and 86400 seconds."
  }

  validation {
    condition = alltrue([
      for record in values(var.dns_record) :
      length(record.records) > 0 &&
      alltrue([
        for ip in record.records :
        can(cidrnetmask("${ip}/32"))
      ])
    ])

    error_message = "Each DNS A record must contain at least one valid IPv4 address."
  }

  validation {
    condition = alltrue([
      for record in values(var.dns_record) :
      length(trimspace(record.name)) > 0 &&
      length(trimspace(record.dns_zone_name)) > 0 &&
      length(trimspace(record.resource_group_name)) > 0
    ])

    error_message = "DNS record name, zone name and resource group name must not be empty."
  }

}
