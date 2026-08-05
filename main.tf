# 1. Orchestrate the Base Networking Layer (VNET, Subnets, Bastion Host)
module "networking" {
  source                = "./modules/networking"
  environment           = var.environment
  location              = var.location
  common_tags           = local.common_tags
  trusted_ssh_ip        = var.trusted_ssh_ip
  dev_subnet_prefix     = var.dev_subnet_prefix
  staging_subnet_prefix = var.staging_subnet_prefix
  prod_subnet_prefix    = var.prod_subnet_prefix
}

# 2. Orchestrate the Secured Compute Layer (NIC, VM, Storage Account, Key Vault)
module "compute" {
  source              = "./compute"
  environment         = var.environment
  location            = var.location
  resource_group_name = module.networking.resource_group_name # Reads from networking outputs
  subnet_id           = module.networking.dev_subnet_id       # Reads from networking outputs
  common_tags         = local.common_tags
}

# 3. Orchestrate the Data Collection Monitoring Pipeline (AMA, DCR, Log Analytics)
module "monitoring" {
  source              = "./modules/monitoring"
  environment         = var.environment
  location            = var.location
  resource_group_name = module.networking.resource_group_name # Reads from networking outputs
  vm_id               = module.compute.vm_id                  # Reads from compute outputs
  key_vault_id        = module.compute.key_vault_id           # Reads from compute outputs
  common_tags         = local.common_tags
}
# 4. Orchestrate the Hardened FinTech Data Ledger Tier (Azure SQL + Private Endpoints)
module "data" {
  source              = "./modules/data"
  environment         = var.environment
  location            = var.location
  resource_group_name = module.networking.resource_group_name # Feeds from networking output
  virtual_network_id  = module.networking.virtual_network_id  # Feeds from networking output
  data_subnet_id      = module.networking.data_subnet_id      # Feeds from networking output
  common_tags         = local.common_tags

  # Secure compliance login keys
  db_admin_user     = "ledgeradmin"
  db_admin_password = "P@ssw0rdEnterpriseSecure2026!" # Securely masked variable
}
