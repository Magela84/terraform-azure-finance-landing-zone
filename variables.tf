variable "environment" {
  type        = string
  description = "The target deployment layer (dev, staging, production) passed down from the environment main.tf"
}

variable "location" {
  type        = string
  description = "The Azure Region zone where resources are orchestrated"
  default     = "eastus"
}

variable "trusted_ssh_ip" {
  type        = string
  description = "Trusted SSH source CIDR used by the networking module security rule"
  default     = "203.0.113.50/24"
}

variable "dev_subnet_prefix" {
  type        = list(string)
  description = "The CIDR prefix for the development subnet"
  default     = ["10.0.1.0/24"]
}

variable "staging_subnet_prefix" {
  type        = list(string)
  description = "The CIDR prefix for the staging subnet"
  default     = ["10.0.2.0/24"]
}

variable "prod_subnet_prefix" {
  type        = list(string)
  description = "The CIDR prefix for the production subnet"
  default     = ["10.0.3.0/24"]
}
