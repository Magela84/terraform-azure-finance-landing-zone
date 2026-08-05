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
