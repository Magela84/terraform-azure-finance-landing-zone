# Azure Landing Zone - Finance Environment
This project uses **Terraform** to provision and manage the core Azure infrastructure needed for the Finance department.  All resources are parameterized for easy customization and safe, repeatable deployments.
---
## 📂 Project Structure
- `main.tf` – Azure resource definitions  - `variables.tf` – All input variables (with descriptions)  - `terraform.tfvars` – Custom values for your environment  - `outputs.tf` – Key outputs after deployment  - `providers.tf` – Azure provider configuration  - `versions.tf` – Version constraints for Terraform and providers  - `README.md` – Project instructions
---
## 🚀 Prerequisites
- [Terraform installed](https://developer.hashicorp.com/terraform/tutorials/aws-get-started/install-cli)- [Azure CLI installed](https://docs.microsoft.com/en-us/cli/azure/install-azure-cli)- Access to an Azure subscription- SSH key pair for VM login
---
## ⚙️ Setup Instructions
1. **Clone this repository and navigate to the project folder**
   ```sh   git clone <your-repo-url>   cd azure-landing-zone-finance

Log in to Azure
az login


Initialize the Terraform workspace
terraform init


Customize variables

Edit terraform.tfvars to match your naming conventions and infrastructure requirements.
Double-check the SSH public key path and unique resource names.



Preview the planned changes
terraform plan


Apply the configuration to deploy resources
terraform apply

Type yes when prompted to confirm.



View the outputs

After deployment, key resource details will be shown in the terminal as defined in outputs.tf.


🛠️ Customizing & Extending
Add or update resources in main.tf as needed.
Update variables in variables.tf and terraform.tfvars for new settings.
Review version constraints in versions.tf before upgrading Terraform or providers.
📝 Notes
Resource names (e.g., storage accounts, key vaults) must be globally unique and meet Azure naming rules.
For secure deployments, never commit sensitive values or private SSH keys to version control.
📚 References
Terraform Docs for Azure
Azure Architecture Center
👥 Contributors
Add your name/team here!

