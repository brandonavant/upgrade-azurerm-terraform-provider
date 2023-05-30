resource "azurerm_app_service_plan" "plan" {
    name = "asp-azurerm-upgrade-demo"
    location = azurerm_resource_group.rg.location
    resource_group_name = azurerm_resource_group.rg.name
    kind = "Linux"
    reserved = true
    
    sku {
        tier = "Standard"
        size = "S1"
    }

    tags = {
      "createdBy" = "Terraform"
    }
}