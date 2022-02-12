output "App_domain_name" {
  value = azurerm_public_ip.todo-ip.fqdn
}

output "App_public_ip" {
  value = azurerm_public_ip.todo-ip.ip_address
}
