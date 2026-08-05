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
