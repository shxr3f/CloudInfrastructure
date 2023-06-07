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