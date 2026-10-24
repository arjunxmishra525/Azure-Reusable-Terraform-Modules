data "azurerm_dns_zone" "datadnszone" {
    for_each = var.dns_record
  name                = each.value.dns_zone_name
  resource_group_name = each.value.resource_group_name
}


resource "azurerm_dns_a_record" "this" {
  for_each = var.dns_record
  name                = each.value.name
  zone_name           = each.value.dns_zone_name
  resource_group_name = each.value.resource_group_name
  ttl     = each.value.ttl
  records = each.value.records
}
