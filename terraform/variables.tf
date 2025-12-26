variable "resource_group_name" {
  description = "Name of the Azure Resource Group"
  type        = string
  default     = "sentiment-maas-rg"
}

variable "location" {
  description = "Azure region"
  type        = string
  default     = "East US"
}

variable "acr_name" {
  description = "Name of the Azure Container Registry"
  type        = string
  default     = "sentimentmaasacr"
}

variable "app_name" {
  description = "Name of the Azure App Service"
  type        = string
  default     = "sentiment-maas-app"
}

variable "alert_email" {
  description = "Email address for alerts"
  type        = string
  default     = "admin@example.com"
}