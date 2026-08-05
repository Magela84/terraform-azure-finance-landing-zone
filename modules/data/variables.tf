variable "resource_group_name" { type = string }
variable "location"            { type = string }
variable "environment"         { type = string }
variable "virtual_network_id"  { type = string }
variable "data_subnet_id"      { type = string }
variable "common_tags"         { type = map(string) }

variable "db_admin_user" {
  type        = string
  description = "The database administrator username"
  default     = "ledgeradmin"
}

variable "db_admin_password" {
  type        = string
  description = "The database administrator password"
  sensitive   = true # Masked from logging out to plain-text consoles
}
