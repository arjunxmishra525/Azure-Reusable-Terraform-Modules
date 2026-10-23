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