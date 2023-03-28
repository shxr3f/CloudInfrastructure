terraform {
  backend "azurerm" {
    resource_group_name  = "rg-terraform"
    storage_account_name = "saterraformsharif"
    container_name       = "tfstate"
    key                  = "ttQtI3f57tTn4FJJzZRut32u5w5RNKdl/T9QQ1afCvegL7+d/1OnghZiGoLHNsWnSWOK0iX2UNNt+AStvflTgg=="
  }
}

provider "azurerm" {
  version = "~>2.0"
  features {}
}
 