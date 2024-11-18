provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "rg" {
  name     = "apim-function-rg"
  location = "eastus"
}

resource "azurerm_storage_account" "storage" {
  name                     = "gokunambifunctionapp"
  resource_group_name      = azurerm_resource_group.rg.name
  location                 = azurerm_resource_group.rg.location
  account_tier             = "Standard"
  account_replication_type = "LRS"
}

resource "azurerm_app_service_plan" "asp" {
  name                = "function-app-plan"
  location            = azurerm_resource_group.rg.location
  resource_group_name = azurerm_resource_group.rg.name
  kind                = "FunctionApp"
  reserved            = true
  sku {
    tier = "Dynamic"
    size = "Y1"
  }
}

resource "azurerm_function_app" "function_app" {
  name                       = "my-function-app"
  resource_group_name        = azurerm_resource_group.rg.name
  location                   = azurerm_resource_group.rg.location
  app_service_plan_id        = azurerm_app_service_plan.asp.id
  storage_account_name       = azurerm_storage_account.storage.name
  storage_account_access_key = azurerm_storage_account.storage.primary_access_key
  version                    = "~4"
  app_settings = {
    FUNCTIONS_WORKER_RUNTIME = "python"
    WEBSITE_RUN_FROM_PACKAGE = "1"
  }
}

resource "azurerm_api_management" "apim" {
  name                = "my-apim"
  location            = azurerm_resource_group.rg.location
  resource_group_name = azurerm_resource_group.rg.name
  publisher_email     = "admin@example.com"
  publisher_name      = "API Admin"
  sku_name            = "Developer_1"
}

resource "azurerm_api_management_api" "api" {
  name                = "my-api"
  resource_group_name = azurerm_resource_group.rg.name
  api_management_name = azurerm_api_management.apim.name
  revision            = "1"
  display_name        = "Sample API"
  path                = "sample"
  protocols           = ["https"]

  import {
    content_format = "swagger-link-json"
    content_value  = "https://example.com/swagger.json" # Replace with your Swagger file URL
  }
}
