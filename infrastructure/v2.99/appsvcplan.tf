resource "azurerm_app_service_plan" "plan" {
    name = "asp-azurerm-upgrade-demo"
    location = data.azurerm_resource_group.rg.location
    resource_group_name = data.azurerm_resource_group.rg.name
    kind = "Linux"
    
    sku {
        tier = "Basic"
        size = "B1"
    }

    tags = {
      "createdBy" = "Terraform"
    }
}