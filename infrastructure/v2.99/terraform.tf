terraform {
  required_providers {
    azurerm = {
      source = "hashicorp/azurerm"
      version = "~> 2.0"
    }
  }

  backend "azurerm" {
    resource_group_name = "rg-azurerm-upgrade-demo"
    storage_account_name = "stazurermupgradedemo"
    container_name = "tfstate"
    key = "prod.terraform.tfstate"
  }
}

provider "azurerm" {
  features {
  }
}