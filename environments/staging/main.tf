provider "azurerm" {
  features {}
  subscription_id = "cb6fa056-2ac2-4910-8f46-04326a9a1ec2"
}

module "staging_vm" {
  source                = "../../"
  environment           = "staging"
  trusted_ssh_ip        = "203.0.113.50/24"
  dev_subnet_prefix     = ["10.1.1.0/24"]
  staging_subnet_prefix = ["10.1.2.0/24"]
  prod_subnet_prefix    = ["10.1.3.0/24"]
}

