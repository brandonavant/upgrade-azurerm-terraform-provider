resource "azurerm_service_plan" "plan" {
  name                = "asp-azurerm-upgrade-demo"
  location            = azurerm_resource_group.rg.location
  resource_group_name = azurerm_resource_group.rg.name
  os_type             = "Linux"
  sku_name            = "S1"

  tags = {
    "createdBy" = "Terraform"
  }
}