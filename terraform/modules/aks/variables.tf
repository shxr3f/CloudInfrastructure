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

variable "node_count" {
  type        = number
  description = "The initial quantity of nodes for the node pool."
  default     = 3
}

variable "msi_id" {
  type        = string
  description = "The Managed Service Identity ID. Set this value if you're running this example using Managed Identity as the authentication method."
  default     = null
}