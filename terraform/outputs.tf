output "vpc_id" {
  value = module.vpc.vpc_id
}

output "eks_cluster_name" {
  value = module.eks.cluster_name
}

output "rds_endpoint" {
  value = module.rds.endpoint
}

output "fsx_dns_name" {
  value = module.fsx.dns_name
}

output "fsx_share_name" {
  value = var.fsx_share_name
}

output "ad_directory_id" {
  value = module.ad.directory_id
}

output "rds_master_secret_name" {
  value = aws_secretsmanager_secret.rds.name
}

output "opcenter_db_secret_name" {
  value = aws_secretsmanager_secret.opcenter_db.name
}

output "ad_admin_secret_name" {
  value = aws_secretsmanager_secret.ad.name
}

output "datasync_task_arn" {
  value = try(aws_datasync_task.s3_to_fsx[0].arn, "")
}
