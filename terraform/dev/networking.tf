# Virtual Network
resource "azurerm_virtual_network" "vnet" {
  name                = "data-platform-vn"
  location            = "eastasia"
  resource_group_name = azurerm_resource_group.rg-data-platform.name
  address_space       = ["10.0.0.0/16"]
}

#Subnet for DB
resource "azurerm_subnet" "db-sn" {
  name                 = "db-sn"
  resource_group_name  = azurerm_resource_group.rg-data-platform.name
  virtual_network_name = azurerm_virtual_network.vnet.name
  address_prefixes     = ["10.0.2.0/24"]
  service_endpoints    = ["Microsoft.Storage"]
  delegation {
    name = "fs"
    service_delegation {
      name = "Microsoft.DBforPostgreSQL/flexibleServers"
      actions = [
        "Microsoft.Network/virtualNetworks/subnets/join/action",
      ]
    }
  }
}

resource "azurerm_private_dns_zone" "db-dns" {
  name                = "sharifdb.postgres.database.azure.com"
  resource_group_name = azurerm_resource_group.rg-data-platform.name
}

resource "azurerm_private_dns_zone_virtual_network_link" "db-nl" {
  name                  = "sharifVnetZone.com"
  private_dns_zone_name = azurerm_private_dns_zone.db-dns.name
  virtual_network_id    = azurerm_virtual_network.vnet.id
  resource_group_name   = azurerm_resource_group.rg-data-platform.name
}

#Subnet for VMs
resource "azurerm_subnet" "vm-sn" {
  name                 = "vm-sn"
  resource_group_name  = azurerm_resource_group.rg-data-platform.name
  virtual_network_name = azurerm_virtual_network.vnet.name
  address_prefixes     = ["10.0.3.0/24"]
}

resource "azurerm_public_ip" "vm-publicip" {
  name                = "vm-publicip"
  resource_group_name = azurerm_resource_group.rg-data-platform.name
  location            = "eastasia"
  allocation_method   = "Static"

  tags = {
    environment = "Dev"
  }
}

resource "azurerm_network_security_group" "vm-nsg" {
  name                = "vm-nsg"
  location            = "eastasia"
  resource_group_name = azurerm_resource_group.rg-data-platform.name

  security_rule {
    name                       = "allowinbound"
    priority                   = 100
    direction                  = "Inbound"
    access                     = "Allow"
    protocol                   = "Tcp"
    source_port_range          = "*"
    destination_port_range     = "*"
    source_address_prefix      = "*"
    destination_address_prefix = "*"
  }

  tags = {
    environment = "Dev"
  }
}

resource "azurerm_network_interface" "vm-nic" {
  name                = "vm-nic"
  location            = "eastasia"
  resource_group_name = azurerm_resource_group.rg-data-platform.name

  ip_configuration {
    name                          = "internal"
    subnet_id                     = azurerm_subnet.vm-sn.id
    private_ip_address_allocation = "Dynamic"
    public_ip_address_id          = azurerm_public_ip.vm-publicip.id
  }
}

resource "azurerm_network_interface_security_group_association" "vm-nsg-assoc" {
  network_interface_id      = azurerm_network_interface.vm-nic.id
  network_security_group_id = azurerm_network_security_group.vm-nsg.id
}

# Subnet for Databricks
resource "azurerm_subnet" "public-databrick-sn" {
  name                 = "public-databrick-sn"
  resource_group_name  = azurerm_resource_group.rg-data-platform.name
  virtual_network_name = azurerm_virtual_network.vnet.name
  address_prefixes     = ["10.0.4.0/24"]

  delegation {
    name = "databricks-del"

    service_delegation {
      actions = [
        "Microsoft.Network/virtualNetworks/subnets/join/action",
        "Microsoft.Network/virtualNetworks/subnets/prepareNetworkPolicies/action",
        "Microsoft.Network/virtualNetworks/subnets/unprepareNetworkPolicies/action",
      ]
      name = "Microsoft.Databricks/workspaces"
    }
  }
}

resource "azurerm_subnet" "private-databrick-sn" {
  name                 = "private-databrick-sn"
  resource_group_name  = azurerm_resource_group.rg-data-platform.name
  virtual_network_name = azurerm_virtual_network.vnet.name
  address_prefixes     = ["10.0.2.0/24"]

  delegation {
    name = "databricks-del"

    service_delegation {
      actions = [
        "Microsoft.Network/virtualNetworks/subnets/join/action",
        "Microsoft.Network/virtualNetworks/subnets/prepareNetworkPolicies/action",
        "Microsoft.Network/virtualNetworks/subnets/unprepareNetworkPolicies/action",
      ]
      name = "Microsoft.Databricks/workspaces"
    }
  }
}

resource "azurerm_network_security_group" "databricks-nsg" {
  name                = "databricks-nsg"
  location            = "eastasia"
  resource_group_name = azurerm_resource_group.rg-data-platform.name
}

resource "azurerm_subnet_network_security_group_association" "private-nsg-assoc" {
  subnet_id                 = azurerm_subnet.private-databrick-sn.id
  network_security_group_id = azurerm_network_security_group.databricks-nsg.id
}

resource "azurerm_subnet_network_security_group_association" "public-nsg-assoc" {
  subnet_id                 = azurerm_subnet.public-databrick-sn.id
  network_security_group_id = azurerm_network_security_group.databricks-nsg.id
}