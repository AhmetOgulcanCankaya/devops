output "container_app_environment_id" {
  value = "Container app env id: ${azurerm_container_app.app.container_app_environment_id}"
}
output "outbound_ip_addresses" {
  value = azurerm_container_app.app.outbound_ip_addresses
  description = "Outbound ip address"
}

output "container_app_ingress_out" {
  value = azurerm_container_app.app.ingress
  description = "Outbound ip address"
}