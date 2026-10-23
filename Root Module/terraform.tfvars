RG = {
  RG1 = {
    name     = "dev-rg"
    location = "Central india"
  }
}
vnet = {
  vnet1 = {
    name                = "dev-vnet"
    resource_group_name = "dev-rg"
    location            = "central India"
    address_space       = ["10.20.0.0/16"]

  }
}

azurerm_subnet = {
  "subnet1" = {
    name                 = "Dev-Frontend-Subnet"
    resource_group_name  = "dev-rg"
    virtual_network_name = "dev-vnet"
    address_prefixes     = ["10.20.1.0/24"]
  }

  subnet2 = {
    name                 = "AzureBastionSubnet"
    resource_group_name  = "dev-rg"
    virtual_network_name = "dev-vnet"
    address_prefixes     = ["10.20.2.0/27"]

  }
}

bastion = {
  bastion1={
    name = "consolelogin"
     name_PIP="console-pip"
     location = "central India"
     resource_group_name=  "dev-rg"
     allocation_method   = "Static"
     sku = "Standard"
     name_ip_configuration = "configuration"  
     data_subnet= "AzureBastionSubnet"               
     virtual_network_name = "dev-vnet"
  }
}

nic = {
  "nic1" = {
    name = "dev-vm-nic"
    location = "Central India"
  resource_group_name = "dev-rg"
  name_ip_config = "internal"
  private_ip_address_allocation = "Dynamic"
  data_subnet = "Dev-Frontend-Subnet"
  virtual_network_name = "dev-vnet"
  }
}