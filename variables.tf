variable "environment" {
  type        = string
  description = "The target deployment layer (dev, staging, production) passed down from the environment main.tf"
}

variable "location" {
  type        = string
  description = "The Azure Region zone where resources are orchestrated"
  default     = "eastus"
}
