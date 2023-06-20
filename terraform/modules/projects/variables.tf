variable "resource_group_name" {
  type        = string
  description = "Name of the resource group."
}

variable "location" {
  type        = string
  default     = "southeastasia"
  description = "Location of the resource group."
}

variable "environment" {
  type        = string
  default     = "dev"
  description = "Environment that AKS is to be Deployed"
}

variable "azurerm_databricks_workspace_scope" {
  type        = string
  description = "Scope of AZD Workspace"
}

variable "azurerm_databricks_workspace_url" {
  type        = string
  description = "URL of AZD Workspace"
}

variable "azurerm_databricks_workspace_id" {
  type        = string
  description = "ID of AZD Workspace"
}

variable "azurerm_storage_account_id" {
  type        = string
  description = "ID of Storage Account"
}