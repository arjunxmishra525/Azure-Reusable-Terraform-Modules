data "azurerm_subnet" "data-blk-subnet" {
  for_each             = var.bastion
  name                 = each.value.data_subnet
  virtual_network_name = each.value.virtual_network_name
  resource_group_name  = each.value.resource_group_name
}


resource "azurerm_public_ip" "bastion-pip" {
  for_each            = var.bastion
  name                = each.value.name_PIP
  location            = each.value.location
  resource_group_name = each.value.resource_group_name
  allocation_method   = each.value.allocation_method
  sku                 = each.value.sku
}

resource "azurerm_bastion_host" "bastion" {
  for_each            = var.bastion
  name                = each.value.name
  location            = each.value.location
  resource_group_name = each.value.resource_group_name
  ip_configuration {
    name                 = each.value.name_ip_configuration
    subnet_id            = data.azurerm_subnet.data-blk-subnet[each.key].id
    public_ip_address_id = azurerm_public_ip.bastion-pip[each.key].id
  }
}