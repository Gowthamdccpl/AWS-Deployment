variable "name" { type = string }
variable "vpc_id" { type = string }
variable "private_subnet_ids" { type = list(string) }
variable "enable_irsa" { type = bool }
variable "cluster_version" {
  type    = string
  default = null
}
variable "eks_managed_node_groups" {
  type = any
}
variable "tags" { type = map(string) }