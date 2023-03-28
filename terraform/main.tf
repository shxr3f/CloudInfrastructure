variable "TFSTATE_KEY" {}


terraform {
  backend "azurerm" {
    resource_group_name  = "rg-terraform"
    storage_account_name = "saterraformsharif"
    container_name       = "tfstate"
    key                  = variable.TFSTATE_KEY
  }
}

provider "azurerm" {
  version = "~>2.0"
  features {}
}
 