variable "db_engine" {
  type = string
}

variable "db_engine_version" {
  type = string
}

variable "db_instance_class" {
  type = string
}

variable "db_username" {
  type = string
}

variable "db_password" {
  type      = string
  sensitive = true
}

variable "name" {
  type = string
}

variable "tags" {
  type = map(string)
}

variable "db_parameter" {
  description = "Parameter group family for the RDS engine"
  type        = string
}

variable "subnet_ids" {
  description = "List of subnet IDs for the RDS subnet group"
  type        = list(string)
}

variable "vpc_id" {
  description = "VPC ID for the RDS security group"
  type        = string
}
