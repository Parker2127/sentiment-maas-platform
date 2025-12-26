output "resource_group_name" {
  description = "Name of the created resource group"
  value       = azurerm_resource_group.sentiment_maas.name
}

output "acr_login_server" {
  description = "ACR login server URL"
  value       = azurerm_container_registry.acr.login_server
}

output "acr_admin_username" {
  description = "ACR admin username"
  value       = azurerm_container_registry.acr.admin_username
  sensitive   = true
}

output "acr_admin_password" {
  description = "ACR admin password"
  value       = azurerm_container_registry.acr.admin_password
  sensitive   = true
}

output "app_service_url" {
  description = "App Service URL"
  value       = azurerm_linux_web_app.app_service.default_hostname
}

output "staging_slot_url" {
  description = "Staging slot URL"
  value       = azurerm_linux_web_app_slot.staging.default_hostname
}

output "production_slot_url" {
  description = "Production slot URL"
  value       = azurerm_linux_web_app_slot.production.default_hostname
}

output "app_insights_instrumentation_key" {
  description = "Application Insights instrumentation key"
  value       = azurerm_application_insights.app_insights.instrumentation_key
  sensitive   = true
}