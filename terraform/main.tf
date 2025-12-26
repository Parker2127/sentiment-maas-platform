terraform {
  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "~> 3.0"
    }
  }
}

provider "azurerm" {
  features {}
}

# Resource Group
resource "azurerm_resource_group" "sentiment_maas" {
  name     = var.resource_group_name
  location = var.location
}

# Container Registry
resource "azurerm_container_registry" "acr" {
  name                = var.acr_name
  resource_group_name = azurerm_resource_group.sentiment_maas.name
  location            = azurerm_resource_group.sentiment_maas.location
  sku                 = "Basic"
  admin_enabled       = true
}

# App Service Plan
resource "azurerm_service_plan" "app_service_plan" {
  name                = "${var.app_name}-plan"
  resource_group_name = azurerm_resource_group.sentiment_maas.name
  location            = azurerm_resource_group.sentiment_maas.location
  os_type             = "Linux"
  sku_name            = "B1"
}

# App Service
resource "azurerm_linux_web_app" "app_service" {
  name                = var.app_name
  resource_group_name = azurerm_resource_group.sentiment_maas.name
  location            = azurerm_resource_group.sentiment_maas.location
  service_plan_id     = azurerm_service_plan.app_service_plan.id

  site_config {
    application_stack {
      docker_image     = "${azurerm_container_registry.acr.login_server}/sentiment-maas"
      docker_image_tag = "latest"
    }
  }

  app_settings = {
    DOCKER_REGISTRY_SERVER_URL      = "https://${azurerm_container_registry.acr.login_server}"
    DOCKER_REGISTRY_SERVER_USERNAME = azurerm_container_registry.acr.admin_username
    DOCKER_REGISTRY_SERVER_PASSWORD = azurerm_container_registry.acr.admin_password
  }
}

# Staging Deployment Slot
resource "azurerm_linux_web_app_slot" "staging" {
  name           = "staging"
  app_service_id = azurerm_linux_web_app.app_service.id

  site_config {
    application_stack {
      docker_image     = "${azurerm_container_registry.acr.login_server}/sentiment-maas"
      docker_image_tag = "staging"
    }
  }

  app_settings = {
    DOCKER_REGISTRY_SERVER_URL      = "https://${azurerm_container_registry.acr.login_server}"
    DOCKER_REGISTRY_SERVER_USERNAME = azurerm_container_registry.acr.admin_username
    DOCKER_REGISTRY_SERVER_PASSWORD = azurerm_container_registry.acr.admin_password
  }
}

# Production Deployment Slot (default)
resource "azurerm_linux_web_app_slot" "production" {
  name           = "production"
  app_service_id = azurerm_linux_web_app.app_service.id

  site_config {
    application_stack {
      docker_image     = "${azurerm_container_registry.acr.login_server}/sentiment-maas"
      docker_image_tag = "production"
    }
  }

  app_settings = {
    DOCKER_REGISTRY_SERVER_URL      = "https://${azurerm_container_registry.acr.login_server}"
    DOCKER_REGISTRY_SERVER_USERNAME = azurerm_container_registry.acr.admin_username
    DOCKER_REGISTRY_SERVER_PASSWORD = azurerm_container_registry.acr.admin_password
  }
}

# Application Insights for monitoring
resource "azurerm_application_insights" "app_insights" {
  name                = "${var.app_name}-insights"
  location            = azurerm_resource_group.sentiment_maas.location
  resource_group_name = azurerm_resource_group.sentiment_maas.name
  application_type    = "web"
}

# Monitor Action Group for alerts
resource "azurerm_monitor_action_group" "alert_group" {
  name                = "${var.app_name}-alerts"
  resource_group_name = azurerm_resource_group.sentiment_maas.name
  short_name          = "sentiment-alerts"

  email_receiver {
    name          = "admin"
    email_address = var.alert_email
  }
}

# Metric Alert for Confidence Score
resource "azurerm_monitor_metric_alert" "confidence_alert" {
  name                = "${var.app_name}-confidence-alert"
  resource_group_name = azurerm_resource_group.sentiment_maas.name
  scopes              = [azurerm_application_insights.app_insights.id]
  description         = "Alert when sentiment confidence drops below threshold"
  severity            = 2

  criteria {
    metric_namespace = "Microsoft.Insights/Components"
    metric_name      = "customMetrics/prediction_confidence_score"
    aggregation      = "Average"
    operator         = "LessThan"
    threshold        = 0.6

    dimension {
      name     = "Metric"
      operator = "Include"
      values   = ["*"]
    }
  }

  action {
    action_group_id = azurerm_monitor_action_group.alert_group.id
  }

  frequency   = "PT5M"  # Check every 5 minutes
  window_size = "PT5M"  # Look at 5-minute window
}