# 🏦 Enterprise Azure Finance Landing Zone

A modular **Azure landing zone built with Terraform** for secure, repeatable, and environment-specific cloud infrastructure deployments.

Designed with regulated industries in mind, the project demonstrates **Infrastructure as Code (IaC), network isolation, secure administrative access, centralized monitoring, and least-privilege security** across Development, Staging, and Production environments.

## Architecture

The solution provisions isolated Azure environments using reusable Terraform modules.

```text
                    Azure
                      │
        ┌─────────────┼─────────────┐
        │             │             │
       Dev         Staging         Prod
        │             │             │
       VNet          VNet          VNet
        │             │             │
     Subnets       Subnets       Subnets
        │             │             │
      NSGs           NSGs          NSGs
        │             │             │
   Private VM     Private VM    Private VM
        │             │             │
        └──────── Azure Bastion ────┘
                      │
        ┌─────────────┼─────────────┐
        │             │             │
    Key Vault      Storage      Monitoring
                                  │
                         Log Analytics
                                  │
                            AMA + DCR
```

## Key Features

* **Terraform IaC** — repeatable and consistent Azure deployments
* **Multi-environment architecture** — isolated Dev, Staging, and Production environments
* **Modular design** — reusable networking, compute, and monitoring modules
* **Private Linux VMs** — workloads deployed without public IP addresses
* **Azure Bastion** — secure administrative access to private VMs
* **Network Security Groups** — controlled network traffic between resources
* **Azure Key Vault** — centralized secrets and key management
* **Azure RBAC & Managed Identity** — least-privilege access to Azure resources
* **Secure Storage** — TLS 1.2 and storage firewall controls
* **Centralized Monitoring** — Azure Monitor, Log Analytics, Azure Monitor Agent, and Data Collection Rules

## Project Structure

```text
.
├── environments/
│   ├── dev/
│   ├── staging/
│   └── prod/
│
├── modules/
│   ├── networking/
│   ├── compute/
│   └── monitoring/
│
├── main.tf
├── providers.tf
├── variables.tf
├── locals.tf
└── versions.tf
```

## Security Design

The landing zone follows **Zero Trust** and **least-privilege** principles.

Key controls include:

* Private virtual machines with no public IP addresses
* Secure VM administration through Azure Bastion
* Network segmentation using VNets, subnets, and NSGs
* Secrets management with Azure Key Vault
* Azure RBAC for controlled resource access
* Managed Identity for credential-free Azure service authentication
* TLS 1.2 enforcement
* Storage firewall protection

## Monitoring

Centralized monitoring provides operational visibility across deployed workloads.

```text
Linux VM
   │
Azure Monitor Agent
   │
Data Collection Rule
   │
Log Analytics Workspace
   │
Azure Monitor
```

**Azure Monitor Agent (AMA)** collects configured telemetry from virtual machines.

**Data Collection Rules (DCRs)** define what data is collected and where it is sent.

**Log Analytics Workspace** centralizes collected monitoring data for querying and analysis.

## Deployment

Authenticate to Azure:

```bash
az login
```

Initialize Terraform:

```bash
terraform init
```

Validate the configuration:

```bash
terraform validate
```

Review the deployment plan:

```bash
terraform plan
```

Deploy the infrastructure:

```bash
terraform apply
```

## Engineering Principles

This project demonstrates:

* Infrastructure as Code
* Reusable Terraform modules
* Environment isolation
* Standardized cloud deployments
* Zero Trust networking
* Least-privilege access
* Secure secrets management
* Centralized monitoring
* Repeatable infrastructure provisioning

## Future Enhancements

Planned improvements include:

* Azure Firewall
* Private Endpoints
* Azure Policy
* Microsoft Defender for Cloud
* GitHub Actions CI/CD
* Terraform remote state
* Azure Cost Management integration

## Technology Stack

**Cloud:** Microsoft Azure
**IaC:** Terraform
**Compute:** Azure Linux Virtual Machines
**Networking:** VNet, Subnets, NSGs, Azure Bastion
**Security:** Key Vault, RBAC, Managed Identity
**Storage:** Azure Storage Account
**Monitoring:** Azure Monitor, Log Analytics, AMA, DCR



---

# Author

**Magela Bobby Akinola**

- GitHub: https://github.com/Magela84
- LinkedIn: https://linkedin.com/in/magela-akinola
- Portfolio: https://magela84.github.io/magela-portfolio-website/
