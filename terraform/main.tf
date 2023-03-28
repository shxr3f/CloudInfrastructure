terraform {
  backend "azurerm" {
    resource_group_name  = "rg-terraform"
    storage_account_name = "saterraformsharif"
    container_name       = "tfstate"
    key                  = "terraform.tfstate"
  }
}

provider "azurerm" {
  version = "~>2.0"
  features {}
}
 