resource "azurerm_resource_group" "rg" {
  location = var.location
  name     = format("rg-aks-%s", var.environment)
}

resource "azurerm_kubernetes_cluster" "k8s" {
  location            = azurerm_resource_group.rg.location
  name                = format("k8s-cluster-%s", var.environment)
  resource_group_name = azurerm_resource_group.rg.name
  dns_prefix          = format("k8scluster%s", var.environment)

  identity {
    type = "SystemAssigned"
  }

  default_node_pool {
    name       = "agentpool"
    vm_size    = "Standard_D2_v2"
    node_count = var.node_count
  }
  linux_profile {
    admin_username = format("ubuntu-%s", var.environment)

    ssh_key {
      key_data = jsondecode(azapi_resource_action.ssh_public_key_gen.output).publicKey
    }
  }
  network_profile {
    network_plugin    = "kubenet"
    load_balancer_sku = "standard"
  }
}