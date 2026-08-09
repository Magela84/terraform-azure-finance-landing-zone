output "vm_id" {
  value       = azurerm_linux_virtual_machine.vm.id
  description = "Exported Virtual Machine resource tracking string"
}

output "storage_account_primary_endpoint" {
  value       = azurerm_storage_account.sa.primary_blob_endpoint
  description = "Exposes storage endpoint to root layer"
}

output "aks_id" {
  value       = azurerm_kubernetes_cluster.aks.id
  description = "ID of the AKS cluster deployed by the compute module"
}
