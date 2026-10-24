
variable "dns_record" {
  description = "Configuration for Azure Public DNS A records."

  type = map(object({
    name                = string
    dns_zone_name       = string
    resource_group_name = string
    ttl                 = optional(number, 300)
    records             = list(string)
  }))

}

