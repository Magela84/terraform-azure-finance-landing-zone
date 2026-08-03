locals {
  # Resource Group
  resource_group_name = "rg-enterprise-shared"

  # Virtual Network
  vnet_name          = "vnet-core-hub"
  vnet_address_space = "10.0.0.0/16"

  # Subnets
  dev_subnet_name       = "snet-dev-01"
  dev_subnet_prefix     = "10.0.1.0/24"
  staging_subnet_name   = "snet-staging-01"
  staging_subnet_prefix = "10.0.2.0/24"
  prod_subnet_name      = "snet-prod-01"
  prod_subnet_prefix    = "10.0.3.0/24"

  # Network Security Group
  dev_nsg_name = "nsg-dev-web"

  # Core Infrastructure Names
  public_ip_name     = "pip-dev-ubuntu-01"
  nic_name           = "nic-dev-ubuntu-01"
  key_vault_name     = "kv-enterprise-shared-01"
  log_analytics_name = "log-enterprise-shared-01" # This line fixes the error you are seeing!

  # Virtual Machine Properties (Modify size here to upgrade or downgrade)
  vm_name             = "vm-dev-ubuntu-01"
  vm_size             = "Standard_B2s"
  admin_username      = "azureuser"
  ssh_public_key_path = "~/.ssh/id_rsa.pub"
  os_disk_name        = "osdisk-dev-ubuntu-01"

  # Storage Account Naming Compliance
  storage_account_name = "stenterpriseshared01"
}
locals {
  common_tags = {
    environment = var.environment
    owner       = "security-team"
    managed_by  = "terraform"
    cost_center = "IT-Operations"
  }
}
