# Providers
terraform {
  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "=3.0.0"
    }
  }
}

# Configure the Microsoft Azure Provider
provider "azurerm" {
  features {
#   // $username = "$(ARM_CLIENT_ID)"
#   // $password = "$(ARM_CLIENT_SECRET)"
#   // $tenantId = "$(ARM_TENANT_ID)"
  }
}