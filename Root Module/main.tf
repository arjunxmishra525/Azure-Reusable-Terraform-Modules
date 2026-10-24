module "resource_group" {
  source = "../azurerm_resource_group"
  RG     = var.RG
}

module "resource_virtual_network" {
  depends_on = [ module.resource_group ]
  source = "../azurerm_virtual_network"
  vnet = var.vnet
}

module "subnet" {
  depends_on = [ module.resource_virtual_network ]
  source = "../azurerm_subnet"
  azurerm_subnet = var.azurerm_subnet
}

module "azurerm_bastion_host" {
  depends_on = [ module.subnet ]
  source = "../azurerm_bastion"
bastion = var.bastion
}

module "nic_card" {
  depends_on = [ module.subnet ]
source = "../azurerm_network_interface" 
nic = var.nic 
}

module "network_security_group" {
  source = "../azurerm_NSG"
  nsg = var.nsg
}

module "nsg_nic_association" {
  depends_on = [ module.nic_card,module.network_security_group ]
  source = "../azurerm_nsg_nic_association"
  nsg_nic = var.nsg_nic
}