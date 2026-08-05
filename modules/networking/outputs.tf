output "resource_group_name" {
  value       = azurerm_resource_group.rg.name
  description = "Exported base Resource Group name"
}

output "location" {
  value       = azurerm_resource_group.rg.location
  description = "Exported location region context"
}

output "dev_subnet_id" {
  value       = azurerm_subnet.dev.id
  description = "Exported primary workload subnet ID"
}
output "virtual_network_id" {
  value       = azurerm_virtual_network.vnet.id
  description = "The global tracking handle ID of the virtual network backbone"
}

output "data_subnet_id" {
  value       = azurerm_subnet.data.id
  description = "The specific backend network routing interface ID of your data subnet"
}
