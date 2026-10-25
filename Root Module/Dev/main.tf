module "resource_group" {
  source = "../../azurerm_resource_group"
  RG     = var.RG
}

module "resource_virtual_network" {
  depends_on = [module.resource_group]
  source     = "../../azurerm_virtual_network"
  vnet       = var.vnet
}

module "subnet" {
  depends_on     = [module.resource_virtual_network]
  source         = "../../azurerm_subnet"
  azurerm_subnet = var.azurerm_subnet
}

module "azurerm_bastion_host" {
  depends_on = [module.subnet]
  source     = "../../azurerm_bastion"
  bastion    = var.bastion
}

module "nic_card" {
  depends_on = [module.subnet]
  source     = "../../azurerm_network_interface"
  nic        = var.nic
}

module "network_security_group" {
  depends_on = [module.resource_group]
  source     = "../../azurerm_NSG"
  nsg        = var.nsg
}

module "nsg_nic_association" {
  depends_on = [module.nic_card, module.network_security_group]
  source     = "../../azurerm_nsg_nic_association"
  nsg_nic    = var.nsg_nic
}


module "azurerm_linux_virtual_machine" {
  depends_on     = [module.nic_card, module.subnet]
  source         = "../../azurerm_linux_vm"
  vm             = var.vm
  admin_password = var.admin_password
  admin_username = var.admin_username
}

module "key_vault" {
  source    = "../../azurerm_key_vault_secret"
  key_vault = var.key_vault

}
module "dns_zone" {
  depends_on = [module.resource_group]
  source     = "../../azurerm_DNS_ZONE"
  dns_zone   = var.dns_zone
}

module "dns_a_records" {
  depends_on = [module.dns_zone]
  source     = "../../azurerm_DNS_RECORD"
  dns_record = var.dns_record
}