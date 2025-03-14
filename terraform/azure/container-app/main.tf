terraform {
  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = ">= 4.20"
    }
  }
}

provider "azurerm" {
  subscription_id = var.subscription_id
  features {}
}

# Create Virtual Network
resource "azurerm_virtual_network" "vnet" {
  name                = var.vnet_name
  location            = var.location
  resource_group_name = var.rg_name
  address_space       = ["10.0.0.0/16"]
}

# Create Subnet for Container App
resource "azurerm_subnet" "subnet" {
  name                 = var.subnet_name
  resource_group_name  = var.rg_name
  virtual_network_name = var.vnet_name  
  address_prefixes     = ["10.0.2.0/23"]

  # Required for Azure Container Apps to integrate with a subnet
  # delegation {
  #   name = "containerapp-delegation"
  #   service_delegation {
  #     name = "Microsoft.App/environments"
  #     actions = [
  #       "Microsoft.Network/virtualNetworks/subnets/join/action"
  #     ]
  #   }
  # }
}

# Create Log Analytics Workspace for monitoring
resource "azurerm_log_analytics_workspace" "log_analytics" {
  name                = "my-containerapp-logs"
  location            = var.location
  resource_group_name = var.rg_name
  sku                 = "PerGB2018"  #Pay as you go
  retention_in_days   = 30  #Log retention
}

# Create Container App Environment
resource "azurerm_container_app_environment" "ca_env" {
  name                 = var.container_app_env
  location             = var.location
  resource_group_name  = var.rg_name
  log_analytics_workspace_id = azurerm_log_analytics_workspace.log_analytics.id

  infrastructure_subnet_id = var.subnet_id
  
}

# Deploy Azure Container App
resource "azurerm_container_app" "app" {
  name                         = var.app_name
  container_app_environment_id = azurerm_container_app_environment.ca_env.id
  resource_group_name          = var.rg_name
  revision_mode                = "Single"

  template {
    container {
      name   = var.container_name
      image  = var.container_image # Replace with your container image
      cpu    = 0.5
      memory = "1Gi"
    }
  }

  ingress {
    external_enabled = true
    target_port      = 80
    traffic_weight {
      percentage = 100
      latest_revision = true
    }
  }

  lifecycle {
    ignore_changes = [ingress] # Prevents conflicts when Terraform applies updates
  }
}