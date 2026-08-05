variable "environment" {
  type        = string
  description = "The target deployment environment (dev, staging, production)"
}

variable "location" {
  type        = string
  description = "The Azure Region where networking resources will be created"
  default     = "eastus"
}

variable "common_tags" {
  type        = map(string)
  description = "Centralized governance tag structure from locals"
}

variable "trusted_ssh_ip" {
  type        = string
  description = "Trusted SSH source CIDR for network security rules"
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

variable "data_subnet_prefix" {
  type        = list(string)
  description = "The isolated CIDR address network footprint block for database private links"
  default     = ["10.0.3.0/24"]
}
