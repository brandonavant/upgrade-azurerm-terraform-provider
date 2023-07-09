resource "azurerm_linux_web_app" "app" {
  name                = "app-azurerm-upgrade-demo"
  location            = azurerm_resource_group.rg.location
  resource_group_name = azurerm_resource_group.rg.name
  service_plan_id     = azurerm_service_plan.plan.id

  site_config {
    application_stack {
      node_version = "18-lts"
    }
  }

  tags = {
    "createdBy" = "Terraform"
  }
}
