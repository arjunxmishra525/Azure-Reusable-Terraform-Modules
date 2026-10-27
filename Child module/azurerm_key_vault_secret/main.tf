# data "azurerm_key_vault" "existing" {
#   for_each            = var.key_vault
#   name                = each.value.key_vault_name
#   resource_group_name = each.value.resource_group_name
# }


# resource "azurerm_key_vault_secret" "keysecret" {
#   for_each     = var.key_vault
#   name         = each.value.name
#   value        = each.value.value
#   key_vault_id = data.azurerm_key_vault.existing[each.key].id
# }