resource "azurerm_app_service" "app" {
  name                = "app-azurerm-upgrade-demo"
  location            = data.azurerm_resource_group.rg.location
  resource_group_name = data.azurerm_resource_group.rg.name
  app_service_plan_id = azurerm_app_service_plan.plan.id

  site_config {
    linux_fx_version = "NODE|18-lts"
  }

  tags = {
    "createdBy" = "Terraform"
  }
}
