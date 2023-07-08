resource "azurerm_resource_group" "rg" {
  name  = "rg-azurerm-upgrade-demo"
  location = "EastUS"
}

data "azurerm_resource_group" "state-rg" {
  name = "rg-azurerm-upgrade-demo-tfstate"
}