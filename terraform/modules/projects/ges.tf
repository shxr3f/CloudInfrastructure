resource "azurerm_data_factory" "ges-adf" {
  name                = "ges-adf"
  location            = var.location
  resource_group_name = var.resource_group_name
  identity {
    type = "SystemAssigned"
  }
}

resource "azurerm_role_assignment" "adf-azd-role" {
  scope                = var.azurerm_databricks_workspace_scope
  role_definition_name = "Contributor"
  principal_id         = azurerm_data_factory.ges-adf.identity[0].principal_id
}

resource "azurerm_role_assignment" "adf-sa-contributor-role" {
  scope                = var.azurerm_storage_account_id
  role_definition_name = "Storage Blob Data Contributor"
  principal_id         = azurerm_data_factory.ges-adf.identity[0].principal_id
}

resource "azurerm_role_assignment" "adf-sa-reader-role" {
  scope                = var.azurerm_storage_account_id
  role_definition_name = "Storage Blob Data Reader"
  principal_id         = azurerm_data_factory.ges-adf.identity[0].principal_id
}

resource "azurerm_data_factory_linked_service_azure_databricks" "ls-adf-azd" {
  name                       = "linked-service-databricks"
  data_factory_id            = azurerm_data_factory.ges-adf.id
  description                = "ADB Linked Service via MSI"
  adb_domain                 = "https://${var.azurerm_databricks_workspace_url}"
  resource_group_name        = var.resource_group_name
  msi_work_space_resource_id = var.azurerm_databricks_workspace_scope

  instance_pool {
    instance_pool_id = "0620-071934-tiled1-pool-kkmy66f4"
    cluster_version = "13.1.x-scala2.12"
    max_number_of_workers = 1
  }
}

resource "azurerm_data_factory_pipeline" "nus-pipeline" {
  name                = "nusPipeline"
  data_factory_id     = azurerm_data_factory.ges-adf.id
  resource_group_name = var.resource_group_name

  activities_json = <<JSON
  [
    {
        "name": "nusDatabricks",
        "type": "DatabricksNotebook",
        "dependsOn": [],
        "policy": {
            "timeout": "0.12:00:00",
            "retry": 0,
            "retryIntervalInSeconds": 30,
            "secureOutput": false,
            "secureInput": false
        },
        "userProperties": [],
        "typeProperties": {
            "notebookPath": "/Repos/e0540641@u.nus.edu/DatabricksScripts/ges/test"
        },
        "linkedServiceName": {
            "referenceName": "linked-service-databricks",
            "type": "LinkedServiceReference"
        }
    }
  ]
  JSON
}

resource "azurerm_data_factory_trigger_blob_event" "blob-trigger" {
  name                  = "fileDropped"
  data_factory_id       = azurerm_data_factory.ges-adf.id
  storage_account_id    = var.azurerm_storage_account_id
  events                = ["Microsoft.Storage.BlobCreated"]
  blob_path_begins_with = "/landing/blobs/ges/nus/"
  blob_path_ends_with   = ".pdf"
  ignore_empty_blobs    = true
  activated             = true

  description = "example description"

  pipeline {
    name = azurerm_data_factory_pipeline.nus-pipeline.name
    parameters = {
      Env = "Dev"
    }
  }
}
