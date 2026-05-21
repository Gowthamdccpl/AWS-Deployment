output "dns_name" {
  value = aws_fsx_windows_file_system.this.dns_name
}

output "arn" {
  value = aws_fsx_windows_file_system.this.arn
}

output "security_group_arn" {
  value = aws_security_group.fsx.arn
}
