# Load local naming values unique to this module context
locals {
  resource_group_name   = "rg-enterprise-shared"
  vnet_name             = "vnet-core-hub"
  vnet_address_space    = "10.0.0.0/16"
  dev_subnet_name       = "snet-dev-01"
  dev_subnet_prefix     = "10.0.1.0/24"
  staging_subnet_name   = "snet-staging-01"
  staging_subnet_prefix = "10.0.2.0/24"
  prod_subnet_name      = "snet-prod-01"
  prod_subnet_prefix    = "10.0.3.0/24"
  dev_nsg_name          = "nsg-dev-web"
  public_ip_name        = "pip-dev-ubuntu-01"
}

# 1. Dedicated Resource Group
resource "azurerm_resource_group" "rg" {
  name     = local.resource_group_name
  location = var.location
}

# 2. Backbone Virtual Network
resource "azurerm_virtual_network" "vnet" {
  name                = local.vnet_name
  address_space       = [local.vnet_address_space]
  location            = azurerm_resource_group.rg.location
  resource_group_name = azurerm_resource_group.rg.name
}

# 3. Environment Subnets
resource "azurerm_subnet" "dev" {
  name                 = local.dev_subnet_name
  resource_group_name  = azurerm_resource_group.rg.name
  virtual_network_name = azurerm_virtual_network.vnet.name
  address_prefixes     = var.dev_subnet_prefix
}

resource "azurerm_subnet" "staging" {
  name                 = local.staging_subnet_name
  resource_group_name  = azurerm_resource_group.rg.name
  virtual_network_name = azurerm_virtual_network.vnet.name
  address_prefixes     = var.staging_subnet_prefix
}

resource "azurerm_subnet" "prod" {
  name                 = local.prod_subnet_name
  resource_group_name  = azurerm_resource_group.rg.name
  virtual_network_name = azurerm_virtual_network.vnet.name
  address_prefixes     = var.prod_subnet_prefix
}

# 4. Network Security Group
resource "azurerm_network_security_group" "dev_nsg" {
  name                = local.dev_nsg_name
  location            = azurerm_resource_group.rg.location
  resource_group_name = azurerm_resource_group.rg.name

  security_rule {
    name                       = "AllowSSH"
    priority                   = 100
    direction                  = "Inbound"
    access                     = "Allow"
    protocol                   = "Tcp"
    source_port_range          = "*"
    destination_port_range     = "22"
    source_address_prefix      = var.trusted_ssh_ip
    destination_address_prefix = "*"
  }
}

# 5. Network Security Group Association
resource "azurerm_subnet_network_security_group_association" "dev_assoc" {
  subnet_id                 = azurerm_subnet.dev.id
  network_security_group_id = azurerm_network_security_group.dev_nsg.id
}

# 6. Public IP (Repurposed cleanly for Bastion)
resource "azurerm_public_ip" "pip" {
  name                = local.public_ip_name
  location            = azurerm_resource_group.rg.location
  resource_group_name = azurerm_resource_group.rg.name
  allocation_method   = "Static"
  sku                 = "Standard"
  tags                = var.common_tags
}

# 7. Dedicated Azure Bastion Subnet
resource "azurerm_subnet" "bastion_subnet" {
  name                 = "AzureBastionSubnet" # Enforced naming rule
  resource_group_name  = azurerm_resource_group.rg.name
  virtual_network_name = azurerm_virtual_network.vnet.name
  address_prefixes     = ["10.0.100.0/27"]
}

# 8. Hardened Azure Bastion Host
resource "azurerm_bastion_host" "bastion" {
  name                = "matrix-${var.environment}-bastion"
  location            = azurerm_resource_group.rg.location
  resource_group_name = azurerm_resource_group.rg.name
  sku                 = "Basic"

  ip_configuration {
    name                 = "bastion-ip-config"
    subnet_id            = azurerm_subnet.bastion_subnet.id
    public_ip_address_id = azurerm_public_ip.pip.id
  }
  tags = var.common_tags
}
# 1. Carve out the isolated Data Subnet footprint within your VNET
resource "azurerm_subnet" "data" {
  name                              = "snet-finance-data-${var.environment}"
  resource_group_name               = azurerm_resource_group.rg.name
  virtual_network_name              = azurerm_virtual_network.vnet.name
  address_prefixes                  = var.data_subnet_prefix
  default_outbound_access_enabled   = false # Explicit zero-trust exit blocking

  # CRITICAL: Mandated to route and expose Private Endpoint connections safely
  private_endpoint_network_policies = "Enabled"
}

# 2. Establish a strict Network Security Group firewall layer for your data tiers
resource "azurerm_network_security_group" "data_nsg" {
  name                = "nsg-finance-data-${var.environment}"
  location            = var.location
  resource_group_name = azurerm_resource_group.rg.name

  tags = var.common_tags
}

# 3. Securely bind the firewall right onto your data subnet interface bounds
resource "azurerm_subnet_network_security_group_association" "data_assoc" {
  subnet_id                 = azurerm_subnet.data.id
  network_security_group_id = azurerm_network_security_group.data_nsg.id
}
