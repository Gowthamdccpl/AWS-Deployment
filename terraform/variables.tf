variable "aws_region" {
  description = "AWS region"
  type        = string
  default     = "us-east-1"
}

variable "name" {
  description = "Base name for resources"
  type        = string
  default     = "opcenter-dev"
}

variable "project" {
  description = "Project name prefix used for tagging and security group names"
  type        = string
  default     = "opcenter"
}

variable "vpc_cidr" {
  type    = string
  default = "172.0.0.0/16"
}

variable "azs" {
  type    = list(string)
  default = ["us-east-1a", "us-east-1b", "us-east-1c"]
}

variable "public_subnets" {
  type    = list(string)
  default = ["172.0.1.0/24", "172.0.2.0/24", "172.0.3.0/24"]
}

variable "private_subnets" {
  type    = list(string)
  default = ["172.0.10.0/24", "172.0.11.0/24", "172.0.12.0/24"]
}

variable "ad_password" {
  description = "Optional Active Directory admin password. If null, Terraform generates and stores one in Secrets Manager."
  type        = string
  sensitive   = true
  default     = null
}

variable "db_username" {
  description = "Master username for the RDS instance"
  type        = string
  default     = "sqladmin"
}

variable "db_password" {
  description = "Optional master password for the RDS instance. If null, Terraform generates and stores one in Secrets Manager."
  type        = string
  sensitive   = true
  default     = null
}

variable "opcenter_db_username" {
  description = "Application database username stored for Helm and post-provisioning jobs."
  type        = string
  default     = "opcenter"
}

variable "opcenter_db_name" {
  description = "Application database name stored for Helm and post-provisioning jobs."
  type        = string
  default     = "opcenter"
}

variable "fsx_domain" {
  description = "Optional FSx/Active Directory domain. If null, Terraform uses <name>.local."
  type        = string
  default     = null
}

variable "s3_seed_bucket_name" {
  description = "Optional S3 bucket name containing files to seed into FSx before Helm deployment."
  type        = string
  default     = ""
}

variable "s3_seed_prefix" {
  description = "Optional S3 prefix inside s3_seed_bucket_name to copy into FSx."
  type        = string
  default     = ""
}

variable "fsx_seed_subdirectory" {
  description = "Optional FSx subdirectory where S3 seed files should be copied."
  type        = string
  default     = ""
}

variable "fsx_share_name" {
  description = "FSx SMB share name used by DataSync and Helm."
  type        = string
  default     = "share"
}

variable "db_engine" {
  description = "Database engine type"
  type        = string
  default     = "sqlserver-se"
}

variable "db_engine_version" {
  description = "Exact engine version string for the RDS instance"
  type        = string
  default     = "15.00.4435.7"
}

variable "db_instance_class" {
  description = "Instance class for the RDS instance"
  type        = string
  default     = "db.t3.medium"
}

variable "db_parameter" {
  description = "Parameter group family for the RDS engine"
  type        = string
  default     = "sqlserver-se-15.0"
}

variable "rds_allocated_storage" {
  description = "Initial allocated storage in GB"
  type        = number
  default     = 50
}

variable "cluster_version" {
  description = "EKS Kubernetes version"
  type        = string
  default     = "1.32"
}

variable "tags" {
  type = map(string)
  default = {
    Project = "opcenter"
    Env     = "dev"
  }
}
