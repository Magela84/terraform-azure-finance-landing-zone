locals {
  nic_name             = "nic-${var.environment}-ubuntu-01"
  vm_name              = "vm-${var.environment}-ubuntu-01"
  vm_size              = "Standard_B2s"
  admin_username       = "azureuser"
  os_disk_name         = "osdisk-${var.environment}-ubuntu-01"
  key_vault_name       = "kv-matrix-shared-${var.environment}-01"
  storage_account_name = "stmatrixshared${var.environment}01"
}

# Fetch your active Azure account context token strings dynamically
data "azurerm_client_config" "current" {}

# 1. Private Network Interface Card (NIC) - No Public IP attached
resource "azurerm_network_interface" "nic" {
  name                = local.nic_name
  location            = var.location
  resource_group_name = var.resource_group_name

  ip_configuration {
    name                          = "internal"
    subnet_id                     = var.subnet_id
    private_ip_address_allocation = "Dynamic"
  }
}

# 2. Hardened Secure Linux Virtual Machine
resource "azurerm_linux_virtual_machine" "vm" {
  name                  = local.vm_name
  location              = var.location
  resource_group_name   = var.resource_group_name
  network_interface_ids = [azurerm_network_interface.nic.id]
  size                  = local.vm_size
  admin_username        = local.admin_username

  admin_ssh_key {
    username   = local.admin_username
    public_key = file("~/.ssh/id_rsa.pub")
  }

  os_disk {
    caching              = "ReadWrite"
    storage_account_type = "Standard_LRS"
    name                 = local.os_disk_name
  }

  source_image_reference {
    publisher = "Canonical"
    offer     = "0001-com-ubuntu-server-jammy"
    sku       = "22_04-lts"
    version   = "latest"
  }

  computer_name                   = local.vm_name
  disable_password_authentication = true

  boot_diagnostics {
    storage_account_uri = null
  }

  tags = var.common_tags
}

# 3. Hardened Security Storage Account
resource "azurerm_storage_account" "sa" {
  name                       = local.storage_account_name
  resource_group_name        = var.resource_group_name
  location                   = var.location
  account_tier               = "Standard"
  account_replication_type   = "LRS"
  https_traffic_only_enabled = true
  min_tls_version            = "TLS1_2"
  shared_access_key_enabled  = false

  network_rules {
    default_action             = "Deny"
    virtual_network_subnet_ids = [var.subnet_id]
    bypass                     = ["AzureServices"]
  }

  tags = var.common_tags
}

# 4. Key Vault Resource Layer
resource "azurerm_key_vault" "kv" {
  name                       = local.key_vault_name
  location                   = var.location
  resource_group_name        = var.resource_group_name
  tenant_id                  = data.azurerm_client_config.current.tenant_id
  sku_name                   = "standard"
  rbac_authorization_enabled = true
}
# 1. Create a User-Assigned Managed Identity for the AKS Cluster (Item 4)
resource "azurerm_user_assigned_identity" "aks_identity" {
  name                = "id-finance-${var.environment}-aks"
  location            = var.location
  resource_group_name = var.resource_group_name

  tags = var.common_tags
}

# 2. Deploy an Enterprise Azure Kubernetes Service (AKS) Private Cluster (Item 5)
resource "azurerm_kubernetes_cluster" "aks" {
  name                    = "aks-finance-${var.environment}-01"
  location                = var.location
  resource_group_name     = var.resource_group_name
  dns_prefix              = "aks-fin-${var.environment}"
  private_cluster_enabled = true # Completely hidden from the public internet

  default_node_pool {
    name           = "nodes"
    node_count     = 2
    vm_size        = "Standard_D2s_v5"
    vnet_subnet_id = var.subnet_id # Deploys directly into your private app subnet
    max_pods       = 110
  }

  node_provisioning_profile {
    mode = "Auto"
  }

  # Assign the Managed Identity instead of legacy passwords/service principals
  identity {
    type         = "UserAssigned"
    identity_ids = [azurerm_user_assigned_identity.aks_identity.id]
  }



  network_profile {
    network_plugin    = "azure" # Azure CNI for enterprise networking performance
    load_balancer_sku = "standard"
  }

  tags = var.common_tags
}
