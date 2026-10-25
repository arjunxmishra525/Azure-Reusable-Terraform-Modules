terraform {
  required_version = ">= 1.5.0"
  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "5.10.0"
    }
  }

  backend "azurerm" {
    resource_group_name  = "backend_pipeline"
    storage_account_name = "pipelinestorageaccount13"
    container_name       = "arjun-tfstate"
    key                  = "dev.terraform.tfstate"
  }
}

provider "azurerm" {
  features {}
}
