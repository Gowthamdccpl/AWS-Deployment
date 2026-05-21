variable "name" { type = string }
variable "ad_password" {
  description = "Password for the Active Directory Admin user"
  type        = string
  sensitive   = true
}
variable "edition" {
  type    = string
  default = "Standard"
}
variable "vpc_id" { type = string }
variable "subnet_ids" {
  description = "List of subnet IDs for the Directory Service"
  type        = list(string)
}
variable "tags" { type = map(string) }