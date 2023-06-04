module "aks-cluster-dev" {
  source = "../modules/aks"

  location = "southeastasia"
  environment = "dev"
  node_count = 2
}