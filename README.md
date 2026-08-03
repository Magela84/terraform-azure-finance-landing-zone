# 🏦 Enterprise Azure Finance Landing Zone (IaC Architecture)

A production-grade, highly secure Azure Multi-Environment Landing Zone architected as **Infrastructure as Code (IaC)** using Terraform modules. This deployment implements a zero-trust network perimeter and isolated pipeline tiers (**Development, Staging, and Production**) to host critical financial workload ledgers, in compliance with rigorous corporate security frameworks.

---

## 🗺️ Architectural Topology Diagram

```text
                  +--------------------------------------------------------+

                  |                 AZURE CLOUD ECOSYSTEM                  |
                  +--------------------------------------------------------+
                                              |
                                     [ Inbound Traffic ]
                                              |
                                              v
                              +-------------------------------+

                              |    Static Public IP (PIP)     |
                              +-------------------------------+
                                              |
                                              v
                              +-------------------------------+

                              |      Azure Bastion Host       |
                              +-------------------------------+
                                              |
                                    ( Secure SSL Proxy )
                                              |
                                              v
+-----------------------------------------------------------------------------------------+

|  VIRTUAL NETWORK (VNET: 10.0.0.0/16)                                                    |
|                                                                                         |
|   +---------------------------------------+     +-------------------------------------+ |
|   | AzureBastionSubnet (10.0.100.0/27)    |     | Private Workload Subnets            | |
|   +---------------------------------------+     +-------------------------------------+ |
|                                                 |  - Dev Subnet     (10.X.1.0/24)     | |
|                                                 |  - Staging Subnet (10.X.2.0/24)     | |
|                                                 |  - Prod Subnet    (10.X.3.0/24)     | |
|                                                 +-------------------------------------+ |
|                                                                    |                    |
|                                                                    v                    |
|                                                 +-------------------------------------+ |
|                                                 | Network Security Group (NSG)        | |
|                                                 +-------------------------------------+ |
|                                                 |  - Rule: Allow SSH (Port 22)        | |
|                                                 |    Source: admin_ip ONLY            | |
|                                                 +-------------------------------------+ |
|                                                                    |                    |
|                                                                    v                    |
|                                                 +-------------------------------------+ |
|                                                 | Private Network Interface (NIC)     | |
|                                                 | (No Public IP Assigned)             | |
|                                                 +-------------------------------------+ |
|                                                                    |                    |
|                                                                    v                    |
|                                                 +-------------------------------------+ |
|                                                 | Secure Ubuntu Linux VM Instance     | |
|                                                 +-------------------------------------+ |
|                                                   |                   |                 |
|                                    [Syslog/Metrics]           [Boot Diagnostics]        |
|                                                   v                   v                 |
+---------------------------------------------------|-------------------|-----------------+

                                                    |                   |
                     +------------------------------+                   |

                     |                                                  |
                     v                                                  v
+------------------------------------------+       +--------------------------------------+

| Log Analytics Workspace (LAW)            |       | Hardened Storage Account             |
+------------------------------------------+       +--------------------------------------+

| - Azure Monitor Agent (AMA) Engine       |       | - TLS 1.2 Minimum Protocol Enforced  |
| - Data Collection Rule (DCR) Pipeline    |       | - Public Nested Item Access Disabled |
| - Structured KQL Ready Log Repositories  |       | - Internal VNET Network Rule Default |
+------------------------------------------+       +--------------------------------------+
                     ^
                     | (Token Validation)
                     v
+------------------------------------------+

| Azure Key Vault (KV)                     |
+------------------------------------------+

| - Tenant ID: azurerm_client_config       |
| - rbac_authorization_enabled = true      |
+------------------------------------------+
```

---

## 🔒 Security Hardening & Compliance Baselines

*   **Zero-Trust Compute Isolation**: Removed public IP mapping endpoints from the workload `azurerm_network_interface`. VMs have purely private addresses, eliminating direct external internet attack vectors.
*   **Perimeter Proxy Management**: Implemented an automated **Azure Bastion Host** within a dedicated `AzureBastionSubnet` to tunnel secure, encrypted administrative SSH connections over SSL through the Azure Portal.
*   **Data Tier Remediation**: Configured strict storage access rules enforcing `min_tls_version = "TLS1_2"`, dropped public container lookups (`allow_nested_items_to_be_public = false`), and enabled a default `Deny` network firewall rule.
*   **Tokenized Authorization Access**: Enabled native Azure RBAC (`rbac_authorization_enabled = true`) inside the Azure Key Vault and dynamically parsed tenant configurations using `azurerm_client_config` data lookups to remove hardcoded credential strings.

---

## 📊 Operational Visibility (Monitoring Pipeline)

To capture comprehensive infrastructure metrics and syslogs without routing data across the open internet, a secure monitoring mesh is built into the architecture:
1.  **Telemetry Collection Extensions**: Deploys the unified **Azure Monitor Agent (AMA)** across virtual machine instances.
2.  **Data Collection Rules (DCR)**: Establishes an `azurerm_monitor_data_collection_rule` mapping precise OS syslog facilities and physical hardware performance counters.
3.  **Analytics Routing**: Securely streams system insights directly into an isolated **Log Analytics Workspace** for auditing and future alert tracking.

---

## 📂 Project & Module Directory Structure

The workspace follows professional layout paradigms, cleanly decoupling components into **Single-Responsibility Child Modules** orchestrated by a slimmed down, unified root layer:

```text
.
├── main.tf              # Master orchestration file linking child modules
├── variables.tf         # Global environment schema variables
├── locals.tf            # DRY repository configuration and common tags mapping
├── providers.tf         # Cloud authentication targets
├── versions.tf          # Terraform binary version constraints
├── modules/
│   ├── networking/      # Manages Resource Groups, VNETs, Subnets, NSGs, and Bastion
│   │   ├── main.tf, variables.tf, outputs.tf
│   ├── compute/         # Manages NICs, Virtual Machines, Hardened Storage, and Key Vault
│   │   ├── main.tf, variables.tf, outputs.tf
│   └── monitoring/      # Manages Log Analytics Workspaces, AMA Extensions, and DCR Rules
│       └── main.tf, variables.tf
└── environments/        # Clean target execution contexts for state separation
    ├── dev/             # Non-prod context configuration parameters
    ├── staging/         # Intermediate test environment configurations
    └── prod/            # Hardened production landing configuration properties
```

---

## 🏗️ Deployment Guide

### 1. Initialize Paths & Module Schemas
Navigate to your specific environment workspace (e.g., Production) and load your child module directories:
```bash
cd environments/prod
terraform init -reconfigure
```

### 2. Verify Code Compilation
Ensure the infrastructure blueprint syntax compiles cleanly against your provider variables:
```bash
terraform validate
```

### 3. Execution Plan Preview
Generate a safe preview of exactly what resources Azure plans to spin up or alter before modifying live data states:
```bash
terraform plan
```
