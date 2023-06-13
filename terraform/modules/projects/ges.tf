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

resource "azurerm_data_factory_linked_service_azure_databricks" "ls-adf-azd" {
  name                       = "linked-service-databricks"
  data_factory_id            = azurerm_data_factory.ges-adf.id
  description                = "ADB Linked Service via MSI"
  adb_domain                 = "https://${var.azurerm_databricks_workspace_url}"
  resource_group_name        = var.resource_group_name
  msi_work_space_resource_id = var.azurerm_databricks_workspace_scope

  new_cluster_config {
    node_type             = "Standard_DS3_v2"
    cluster_version       = "12.2.x-scala2.12"
    min_number_of_workers = 1
    max_number_of_workers = 1
    driver_node_type      = "Standard_DS3_v2"
  }
}

resource "azurerm_data_factory_pipeline" "test-pipeline" {
  name                = "testPipeline"
  data_factory_id     = azurerm_data_factory.ges-adf.id
  resource_group_name = var.resource_group_name

  activities_json = <<JSON
  [
    {
        "name": "testDatabricks",
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