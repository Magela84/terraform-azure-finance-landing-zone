output "storage_account_primary_endpoint" {
  description = "The primary blob service endpoint URL for the storage account."
  value       = module.compute.storage_account_primary_endpoint
}
