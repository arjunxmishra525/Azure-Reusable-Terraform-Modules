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
  subnet1 = {
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
  bastion1 = {
    name                  = "consolelogin"
    name_PIP              = "console-pip"
    location              = "central India"
    resource_group_name   = "dev-rg"
    allocation_method     = "Static"
    sku                   = "Standard"
    name_ip_configuration = "configuration"
    data_subnet           = "AzureBastionSubnet"
    virtual_network_name  = "dev-vnet"
  }
}

nic = {
  "nic1" = {
    name                          = "dev-vm-nic"
    location                      = "Central India"
    resource_group_name           = "dev-rg"
    name_ip_config                = "internal"
    private_ip_address_allocation = "Dynamic"
    data_subnet                   = "Dev-Frontend-Subnet"
    virtual_network_name          = "dev-vnet"
  }
}


nsg = {
  "nsg1" = {
    name                       = "dev-nsg"
    location                   = "Central India"
    resource_group_name        = "dev-rg"
    name_rule                  = "test123"
    priority                   = 100
    direction                  = "Outbound"
    access                     = "Allow"
    protocol                   = "Tcp"
    source_port_range          = "*"
    destination_port_range     = "*"
    source_address_prefix      = "*"
    destination_address_prefix = "*"
  }
}
nsg_nic = {
  nsg_nic1 = {
    nic_name            = "dev-vm-nic"
    resource_group_name = "dev-rg"
    nsg_name            = "dev-nsg"
  }
}

vm = {
  vm1 = {
    nic_name                        = "dev-vm-nic"
    name                            = "frontendvirtualmachine"
    resource_group_name             = "dev-rg"
    size                            = "Standard_D4_v5"
    location                        = "Central India"
    disable_password_authentication = false
    caching                         = "ReadWrite"
    storage_account_type            = "Standard_LRS"
    publisher                       = "Canonical"
    offer                           = "0001-com-ubuntu-server-jammy"
    source_image_reference_sku      = "22_04-lts"
    version                         = "latest"

  }
}

key_vault = {
  key_vault_secret1 = {
    name                = "adminusername1"
    value               = "arjunfrontendvm"
    key_vault_name      = "pipelinekeyvaultG103"
    resource_group_name = "backend_pipeline"

  }

  key_vault_secret2 = {
    name                = "adminpassword1"
    value               = "Arjunmishra@20"
    key_vault_name      = "pipelinekeyvaultG103"
    resource_group_name = "backend_pipeline"
  }
}

dns_zone = {
  "dns_zone1" = {
    name                = "b18g103.online"
    resource_group_name = "dev-rg"
  }
}

dns_record = {
  "record1" = {
    name                = "login"
    dns_zone_name       = "b18g103.online"
    resource_group_name = "dev-rg"
    ttl                 = 3600
    records             = ["49.45.40.50"]
  }
}


