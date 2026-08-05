variable "environment" {
  type        = string
  description = "The target deployment environment (dev, staging, production)"
}

variable "resource_group_name" {
  type        = string
  description = "The name of the Resource Group passed from the networking module"
}

variable "location" {
  type        = string
  description = "The region passed from the networking module"
}

variable "vm_id" {
  type        = string
  description = "The target Virtual Machine ID passed from the compute module"
}

variable "common_tags" {
  type        = map(string)
  description = "Centralized governance tag structure from locals"
}
