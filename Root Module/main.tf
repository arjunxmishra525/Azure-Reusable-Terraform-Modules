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
  depends_on = [ var.azurerm_subnet ]
source = "../azurerm_network_interface" 
nic = var.nic 
}