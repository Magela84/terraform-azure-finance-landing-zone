# 1. Generate an Azure SQL Logical Server Instance
resource "azurerm_mssql_server" "sql_server" {
  name                         = "sql-ledger-${var.environment}-01"
  resource_group_name          = var.resource_group_name
  location                     = var.location
  version                      = "12.0"
  administrator_login          = var.db_admin_user
  administrator_login_password = var.db_admin_password
  minimum_tls_version          = "1.2" # Mandated by regulatory frameworks

  tags = var.common_tags
}

# 2. Provision the Highly-Available Financial Transaction Ledger Database
resource "azurerm_mssql_database" "sql_db" {
  name         = "db-transactions-${var.environment}"
  server_id    = azurerm_mssql_server.sql_server.id
  collation    = "SQL_Latin1_General_CP1_CI_AS"
  license_type = "BasePrice"
  sku_name     = "Basic" # Optimized budget tier for testing sandboxes

  tags = var.common_tags
}

# 3. Create a Private DNS Zone for internal database name resolution
resource "azurerm_private_dns_zone" "sql_dns" {
  name                = "privatelink.database.windows.net"
  resource_group_name = var.resource_group_name

  tags = var.common_tags
}

# 4. Link the Private DNS Zone directly back into our Core VNET
resource "azurerm_private_dns_zone_virtual_network_link" "dns_link" {
  name                 = "dnslink-sql-${var.environment}"
  private_dns_zone_id  = azurerm_private_dns_zone.sql_dns.id
  virtual_network_id   = var.virtual_network_id
  registration_enabled = false
}

# 5. Establish the Private Endpoint to strip the Database off the open internet
resource "azurerm_private_endpoint" "sql_pe" {
  name                = "pe-sql-${var.environment}-01"
  location            = var.location
  resource_group_name = var.resource_group_name
  subnet_id           = var.data_subnet_id # Drops a private network interface into this specific subnet

  private_service_connection {
    name                           = "psc-sql-${var.environment}"
    private_connection_resource_id = azurerm_mssql_server.sql_server.id
    subresource_names              = ["sqlServer"]
    is_manual_connection           = false
  }

  private_dns_zone_group {
    name                 = "dns-group-sql"
    private_dns_zone_ids = [azurerm_private_dns_zone.sql_dns.id]
  }

  tags = var.common_tags
}
