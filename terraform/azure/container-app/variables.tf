variable "subscription_id" {
  type = string
  default = "$subscription_id"
  description = "Container image and version to be deployed."
}
variable "rg_name" {
  type = string
  default = "rg_name"
  description = "Container image and version to be deployed."
}
variable "container_image" {
  type = string
  default = "nginx:latest"
  description = "Container image and version to be deployed."
}

variable "container_name" {
  type = string
  default = "nginx"
  description = "Container name to be deployed."
}

variable "app_name" {
  type = string
  default = "basic-nginx"
  description = "App name to be deployed."
}

variable "location" {
  type = string
  default = "West Europe" 
  description = "Region for app to be deployed."
}

variable "resource_group_name" {
  type = string
  default = "rg-dev" #change
  description = "Resource group name for app to be deployed."
}

variable "container_app_env" {
  type = string
  default = "container-app-env" #change
  description = "Container app env name for app to be deployed."
}

variable "vnet_name" {
  type = string
  default = "vnet-container-app-dev-01" #change
  description = "Resource group name for app to be deployed."
}

variable "subnet_name" {
  type = string
  default = "snet-container-app-dev-01" #change
  description = "Resource group name for app to be deployed."
}

variable "subnet_id" {
  type = string
  default = "subnet_id" #change
  description = "Resource group name for app to be deployed."
}

