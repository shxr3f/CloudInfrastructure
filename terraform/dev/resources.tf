#Resource Group for Primary Resources
resource "azurerm_resource_group" "rg-data-platform" {
  name     = "rg-data-platform"
  location = "southeastasia"
}

# Storage Account
resource "azurerm_storage_account" "sa-data-platform" {
  name                     = "sharifstdataplatform"
  resource_group_name      = azurerm_resource_group.rg-data-platform.name
  location                 = azurerm_resource_group.rg-data-platform.location
  account_tier             = "Standard"
  account_replication_type = "GRS"

  tags = {
    environment = "dev"
  }
}

resource "azurerm_storage_container" "landing-container" {
  name                  = "landing"
  storage_account_name  = azurerm_storage_account.sa-data-platform.name
  container_access_type = "private"
}

resource "azurerm_storage_container" "archive-container" {
  name                  = "archive"
  storage_account_name  = azurerm_storage_account.sa-data-platform.name
  container_access_type = "private"
}

# Databricks Workspace
resource "azurerm_databricks_workspace" "databricks-workspace" {
  name                = "databricks-workspace"
  resource_group_name = azurerm_resource_group.rg-data-platform.name
  location            = azurerm_resource_group.rg-data-platform.location
  sku                 = "premium"

  public_network_access_enabled = true
  managed_resource_group_name   = "rg-databricks"

  custom_parameters {
    no_public_ip        = true
    public_subnet_name  = azurerm_subnet.public-databrick-sn.name
    private_subnet_name = azurerm_subnet.private-databrick-sn.name
    virtual_network_id  = azurerm_virtual_network.vnet.id

    public_subnet_network_security_group_association_id  = azurerm_subnet_network_security_group_association.public-nsg-assoc.id
    private_subnet_network_security_group_association_id = azurerm_subnet_network_security_group_association.private-nsg-assoc.id
  }

  tags = {
    Environment = "dev"
  }
}

# Virtual Machine as JumpHost

resource "azurerm_linux_virtual_machine" "general-vm" {
  name                            = "general-vm"
  resource_group_name             = azurerm_resource_group.rg-data-platform.name
  location                        = "eastasia"
  size                            = "Standard_B1s"
  admin_username                  = "adminuser"
  admin_password                  = "H@Sh1CoR3"
  disable_password_authentication = false
  network_interface_ids = [
    azurerm_network_interface.vm-nic.id,
  ]

  os_disk {
    caching              = "ReadWrite"
    storage_account_type = "Standard_LRS"
  }

  source_image_reference {
    publisher = "Canonical"
    offer     = "0001-com-ubuntu-server-focal"
    sku       = "20_04-lts"
    version   = "latest"
  }
}


# Databases

resource "azurerm_postgresql_flexible_server" "db-server" {
  name                   = "sharif-psqlflexibleserver"
  resource_group_name    = azurerm_resource_group.rg-data-platform.name
  location               = "eastasia"
  version                = "12"
  delegated_subnet_id    = azurerm_subnet.db-sn.id
  private_dns_zone_id    = azurerm_private_dns_zone.db-dns.id
  administrator_login    = "psqladmin"
  administrator_password = "H@Sh1CoR3!"
  zone                   = "1"

  storage_mb = 32768

  sku_name   = "B_Standard_B1ms"
  depends_on = [azurerm_private_dns_zone_virtual_network_link.db-nl]

}

# ADF Resource Group
resource "azurerm_resource_group" "rg-data-projects" {
  name     = "rg-data-projects"
  location = "southeastasia"
}

# Projects
# module "data-projects" {
#   source                             = "../modules/projects"
#   resource_group_name                = azurerm_resource_group.rg-data-projects.name
#   environment                        = "dev"
#   location                           = azurerm_resource_group.rg-data-projects.location
#   azurerm_databricks_workspace_scope = azurerm_databricks_workspace.databricks-workspace.id
#   azurerm_databricks_workspace_url   = azurerm_databricks_workspace.databricks-workspace.workspace_url
#   azurerm_databricks_workspace_id    = azurerm_databricks_workspace.databricks-workspace.workspace_id
# }