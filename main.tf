# 1. Orchestrate the Base Networking Layer (VNET, Subnets, Bastion Host)
module "networking" {
  source      = "./modules/networking"
  environment = var.environment
  location    = var.location
  common_tags = local.common_tags
}

# 2. Orchestrate the Secured Compute Layer (NIC, VM, Storage Account, Key Vault)
module "compute" {
  source              = "./modules/compute"
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
  common_tags         = local.common_tags
}
