terraform {
  required_providers {
    azurerm = {
      source = "hashicorp/azurerm"
      version = "~> 2.0"
    }
  }

  backend "azurerm" {
    resource_group_name = "rg-azurerm-upgrade-demo-tfstate"
    storage_account_name = "stazurermupgradetfstate"
    container_name = "tfstate"
    key = "prod.terraform.tfstate"
  }
}

provider "azurerm" {
  features {
  }
}