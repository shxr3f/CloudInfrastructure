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