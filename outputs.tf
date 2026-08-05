output "vm_id" {
  description = "The ID of the compute virtual machine."
  value       = module.compute.vm_id
}

output "storage_account_primary_endpoint" {
  description = "The primary blob service endpoint URL for the storage account."
  value       = module.compute.storage_account_primary_endpoint
}

output "key_vault_id" {
  description = "The ID of the compute key vault."
  value       = module.compute.key_vault_id
}

output "aks_id" {
  description = "The ID of the deployed compute AKS cluster."
  value       = module.compute.aks_id
}
