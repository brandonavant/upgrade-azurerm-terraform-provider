resource "azurerm_app_service" "app" {
  name                = "app-azurerm-upgrade-demo"
  location            = azurerm_resource_group.rg.location
  resource_group_name = azurerm_resource_group.rg.name
  app_service_plan_id = azurerm_app_service_plan.plan.id

  site_config {
    linux_fx_version = "NODE|lts"
  }

  tags = {
    "createdBy" = "Terraform"
  }
}
