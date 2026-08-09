locals {
  log_analytics_name = "log-matrix-shared-${var.environment}-01"
}

# 1. Centralized Log Analytics Workspace
resource "azurerm_log_analytics_workspace" "log" {
  name                = local.log_analytics_name
  location            = var.location
  resource_group_name = var.resource_group_name
  sku                 = "PerGB2018"
  retention_in_days   = 30
}

# 2. Install the Azure Monitor Agent (AMA) Extension on the Compute Target
resource "azurerm_virtual_machine_extension" "ama" {
  name                       = "AzureMonitorLinuxAgent"
  virtual_machine_id         = var.vm_id
  publisher                  = "Microsoft.Azure.Monitor"
  type                       = "AzureMonitorLinuxAgent"
  type_handler_version       = "1.29"
  auto_upgrade_minor_version = true
}

# 3. Data Collection Rule (DCR) Pipeline Engine
resource "azurerm_monitor_data_collection_rule" "dcr" {
  name                = "matrix-${var.environment}-dcr"
  resource_group_name = var.resource_group_name
  location            = var.location

  destinations {
    log_analytics {
      workspace_resource_id = azurerm_log_analytics_workspace.log.id
      name                  = "destination-workspace"
    }
  }

  data_sources {
    # Linux OS Syslogs Configuration
    syslog {
      facility_names = ["auth", "authpriv", "cron", "daemon", "kern", "syslog", "user"]
      log_levels     = ["Warning", "Error", "Critical", "Alert", "Emergency"]
      streams        = ["Microsoft-Syslog"]
      name           = "syslog-datasource"
    }

    # VM Core Performance Hardware Metrics
    performance_counter {
      streams                       = ["Microsoft-InsightsMetrics"]
      sampling_frequency_in_seconds = 60
      counter_specifiers = [
        "\\Processor(_Total)\\% Processor Time",
        "\\Memory\\Available MBytes"
      ]
      name = "metric-datasource"
    }
  }

  data_flow {
    streams      = ["Microsoft-Syslog", "Microsoft-InsightsMetrics"]
    destinations = ["destination-workspace"]
  }

  tags = var.common_tags
}

# 4. Bridge Rule to Virtual Machine Target
resource "azurerm_monitor_data_collection_rule_association" "dcra" {
  name                    = "matrix-${var.environment}-dcra"
  target_resource_id      = var.vm_id
  data_collection_rule_id = azurerm_monitor_data_collection_rule.dcr.id
  description             = "Associates VM to Azure Monitor Agent data collection rule"

  depends_on = [azurerm_virtual_machine_extension.ama]
}
# 1. Provision a Hardened Recovery Services Vault for Disaster Recovery
resource "azurerm_recovery_services_vault" "vault" {
  name                = "rsv-finance-${var.environment}-01"
  location            = var.location
  resource_group_name = var.resource_group_name
  sku                 = "Standard"
  storage_mode_type   = "GeoRedundant" # Mirrors data across multiple regions for safety

  tags = var.common_tags
}

# 2. Establish a daily Automated Backup Policy for Virtual Machines
resource "azurerm_backup_policy_vm" "vm_policy" {
  name                = "bkp-policy-daily-vm"
  resource_group_name = var.resource_group_name
  recovery_vault_name = azurerm_recovery_services_vault.vault.name

  timezone = "UTC"

  backup {
    frequency = "Daily"
    time      = "23:00" # Runs at night when transaction volume is low
  }

  retention_daily {
    count = 30 # Retains copies for 30 days to satisfy standard audit cycles
  }
}

# 3. Associate your Primary Virtual Machine into the Automated Backup Schedule
resource "azurerm_backup_protected_vm" "protected_vm" {
  resource_group_name = var.resource_group_name
  recovery_vault_name = azurerm_recovery_services_vault.vault.name
  source_vm_id        = var.vm_id # Dynamically links back to your compute module VM
  backup_policy_id    = azurerm_backup_policy_vm.vm_policy.id
}
# 1. Enforce Corporate Data Residency via Azure Policy (Item 2)
resource "azurerm_subscription_policy_assignment" "data_sovereignty" {
  name                 = "policy-finance-sovereignty"
  subscription_id      = "/subscriptions/00000000-0000-0000-0000-000000000000"                                       # Target billing boundary
  policy_definition_id = "/providers/Microsoft.Authorization/policyDefinitions/e56962a6-4747-49cd-b67b-bf8b01975c4c" # Azure Built-in "Allowed Locations" ID
  description          = "Restricts financial resource deployments strictly to compliant geographic regions"
  display_name         = "Enforce Finance Data Sovereignty"

  # Enforce eastus as the only allowed deployment zone
  parameters = <<PARAMETERS
{
  "allowedLocations": {
    "value": ["eastus"]
  }
}
PARAMETERS
}

# 2. Wire Diagnostic Settings to stream security logs to Log Analytics (Item 2)
resource "azurerm_monitor_diagnostic_setting" "kv_diagnostics" {
  name                       = "ds-finance-keyvault-audit"
  target_resource_id         = var.key_vault_id
  log_analytics_workspace_id = azurerm_log_analytics_workspace.log.id

  enabled_log {
    category = "AuditEvent" # Captures every single token, password, and credential lookup attempt
  }

  enabled_metric {
    category = "AllMetrics"
  }
}
