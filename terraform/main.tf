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
  https_only                 = true
  app_settings = {
    FUNCTIONS_WORKER_RUNTIME = "python"
    WEBSITE_RUN_FROM_PACKAGE = "1"
  }
}

resource "azurerm_api_management" "apim" {
  name                = "my-apim-goks"
  location            = azurerm_resource_group.rg.location
  resource_group_name = azurerm_resource_group.rg.name
  publisher_email     = "admin@example.com"
  publisher_name      = "API Admin"
  sku_name            = "Developer_1"
}

resource "azurerm_api_management_api" "api" {
  name                = "HelloWorldAPI"
  resource_group_name = azurerm_resource_group.rg.name
  api_management_name = azurerm_api_management.apim.name
  revision            = "1"
  display_name        = "HelloWorld API"
  path                = "helloworld"
  protocols           = ["https"]
  service_url         = "https://${azurerm_function_app.function.default_hostname}"
}

# Outputs
output "resource_group_name" {
  value = azurerm_resource_group.rg.name
}

output "function_app_url" {
  value = azurerm_function_app.function.default_hostname
}

output "apim_url" {
  value = azurerm_api_management.apim.gateway_url
}
