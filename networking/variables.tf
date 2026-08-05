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
