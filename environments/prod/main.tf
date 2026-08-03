provider "azurerm" {
  features {}
  subscription_id = "cb6fa056-2ac2-4910-8f46-04326a9a1ec2"
}

module "prod_vm" {
  source      = "../../"
  environment = "production"
}
