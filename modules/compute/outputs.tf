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

output "key_vault_id" {
  description = "The ID of the compute Key Vault."
  value       = azurerm_key_vault.kv.id
}