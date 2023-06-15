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

  tags = {
    Environment = "dev"
  }
}

# # Virtual Network
# resource "azurerm_virtual_network" "vnet" {
#   name                = "data-platform-vn"
#   location            = "eastasia"
#   resource_group_name = azurerm_resource_group.rg-data-platform.name
#   address_space       = ["10.0.0.0/16"]
# }

# resource "azurerm_subnet" "mysql-sn" {
#   name                 = "mysql-sn"
#   resource_group_name  = azurerm_resource_group.rg-data-platform.name
#   virtual_network_name = azurerm_virtual_network.vnet.name
#   address_prefixes     = ["10.0.2.0/24"]
#   service_endpoints    = ["Microsoft.Storage"]
#   delegation {
#     name = "fs"
#     service_delegation {
#       name = "Microsoft.DBforMySQL/flexibleServers"
#       actions = [
#         "Microsoft.Network/virtualNetworks/subnets/join/action",
#       ]
#     }
#   }
# }

# resource "azurerm_private_dns_zone" "db-dns" {
#   name                = "sharifdb.postgres.database.azure.com"
#   resource_group_name = azurerm_resource_group.rg-data-platform.name
# }

# resource "azurerm_private_dns_zone_virtual_network_link" "db-nl" {
#   name                  = "sharifVnetZone.com"
#   private_dns_zone_name = azurerm_private_dns_zone.db-dns.name
#   virtual_network_id    = azurerm_virtual_network.vnet.id
#   resource_group_name   = azurerm_resource_group.rg-data-platform.name
# }

# # Databases

# resource "azurerm_postgresql_flexible_server" "db-server" {
#   name                   = "sharif-psqlflexibleserver"
#   resource_group_name    = azurerm_resource_group.rg-data-platform.name
#   location               = "eastasia"
#   version                = "12"
#   delegated_subnet_id    = azurerm_subnet.mysql-sn.id
#   private_dns_zone_id    = azurerm_private_dns_zone.db-dns.id
#   administrator_login    = "psqladmin"
#   administrator_password = "H@Sh1CoR3!"
#   zone                   = "1"

#   storage_mb = 32768

#   sku_name   = "B_Standard_B1ms"
#   depends_on = [azurerm_private_dns_zone_virtual_network_link.db-nl]

# }

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