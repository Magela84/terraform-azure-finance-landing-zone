# Architecture Decision Record (ADR)
## Status
Approved
## Context
We need to provide reliable management access to our secure virtual machines residing within our private subnets. Exposing port 22 directly to the open internet via public IPs invites continuous brute-force attack vectors.
## Decision
We choose to deploy an **Azure Bastion Host** within a dedicated `AzureBastionSubnet` (/27). All public IP configurations have been removed from the computing hosts. Administrative SSH traffic is securely proxied over an SSL browser tunnel.
## Consequences
*   **Positive**: The network attack perimeter is minimized; hosts use purely internal IP tracking schemes.
*   **Positive**: Centralized access auditing through integration with our Log Analytics Workspace.
*   **Negative**: Additional infrastructure pricing costs associated with standard Bastion hosting.
