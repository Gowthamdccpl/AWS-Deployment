variable "vpc_id" { type = string }
variable "subnet_ids" {
  type = list(string)
}
variable "preferred_subnet" {
  type = string
}
variable "directory_id" { type = string }
variable "throughput_mbps" {
  type    = number
  default = 64
}
variable "storage_capacity" {
  type    = number
  default = 1024
}
variable "tags" { type = map(string) }