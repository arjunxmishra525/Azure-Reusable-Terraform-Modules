variable "nsg" {
  type = map(object({
    name                = string
    location            = string
    resource_group_name = string
    name_rule = string
    protocol = string
    access = string
    direction = string
    priority = number
    source_port_range           = string
  destination_port_range      = string
  source_address_prefix       = string
  destination_address_prefix  = string
 
  }))
}

