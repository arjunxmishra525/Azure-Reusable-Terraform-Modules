resource "azurerm_dns_zone" "DNSZONE-public" {
    for_each=var.dns_zone
  name                = each.value.name
  resource_group_name = each.value.resource_group_name
}

