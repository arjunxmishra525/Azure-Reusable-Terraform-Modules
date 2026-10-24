data "azurerm_network_interface" "existing_nic" {
    for_each = var.nsg_nic
  name                = each.value.nic_name
  resource_group_name = each.value.resource_group_name
}

data "azurerm_network_security_group" "data_nsg" {
    for_each = var.nsg_nic
  name                = each.value.nsg_name
  resource_group_name = each.value.resource_group_name
}


resource "azurerm_network_interface_security_group_association" "nsg_nic" {
    for_each = var.nsg_nic
  network_interface_id      = data.azurerm_network_interface.existing_nic[each.key].id
  network_security_group_id = data.azurerm_network_security_group.data_nsg[each.key].id
}