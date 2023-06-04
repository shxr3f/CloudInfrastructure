terraform {
  backend "azurerm" {
    resource_group_name  = "rg-terraform"
    storage_account_name = "saterraformsharif"
    container_name       = "tfstate"
    key                  = "terraform.tfstate"
  }

  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "~>2.0"
    }
    azapi = {
      source  = "azure/azapi"
      version = "~>1.5.0"
    }
    random = {
      source  = "hashicorp/random"
      version = "~>3.0"
    }
    time = {
      source  = "hashicorp/time"
      version = "0.9.1"
    }
  }
}

provider "azurerm" {
  features {}
}

provider "azapi" {
}