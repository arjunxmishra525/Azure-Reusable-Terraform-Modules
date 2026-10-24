data "azurerm_network_interface" "data_nic1" {
  for_each            = var.vm
  name                = each.value.nic_name
  resource_group_name = each.value.resource_group_name
}


resource "azurerm_linux_virtual_machine" "virtual_network_name" {
  for_each                        = var.vm
  name                            = each.value.name
  resource_group_name             = each.value.resource_group_name
  location                        = each.value.location
  size                            = lookup(each.value, "size", "Standard_D4_v5")
  admin_username                  = var.admin_username
  admin_password                  = var.admin_password
  disable_password_authentication = lookup(each.value, "disable_password_authentication", false)
  network_interface_ids = [
    data.azurerm_network_interface.data_nic1[each.key].id
  ]

  os_disk {
    caching              = each.value.caching
    storage_account_type = each.value.storage_account_type
  }

  source_image_reference {
    publisher = each.value.publisher
    offer     = each.value.offer
    sku       = each.value.source_image_reference_sku
    version   = each.value.version
  }
}
