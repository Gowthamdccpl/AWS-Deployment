resource "random_password" "ad_admin" {
  length           = 24
  special          = true
  override_special = "!#$%&*()-_=+[]{}<>:?"
}

resource "random_password" "rds_master" {
  length           = 24
  special          = true
  override_special = "!#$%&*()-_=+[]{}<>:?"
}

resource "random_password" "opcenter_db_user" {
  length           = 24
  special          = true
  override_special = "!#$%&*()-_=+[]{}<>:?"
}

locals {
  ad_domain           = coalesce(var.fsx_domain, "${var.name}.local")
  ad_admin_password   = coalesce(var.ad_password, random_password.ad_admin.result)
  rds_master_password = coalesce(var.db_password, random_password.rds_master.result)
}

resource "aws_secretsmanager_secret" "rds" {
  name                    = "${var.name}/rds/master"
  description             = "RDS SQL Server master credentials for ${var.name}"
  recovery_window_in_days = 0
}

resource "aws_secretsmanager_secret_version" "rds" {
  secret_id = aws_secretsmanager_secret.rds.id
  secret_string = jsonencode({
    username = var.db_username
    password = local.rds_master_password
  })
}

resource "aws_secretsmanager_secret" "ad" {
  name                    = "${var.name}/ad/admin"
  description             = "AWS Managed Microsoft AD admin credentials for ${var.name}"
  recovery_window_in_days = 0
}

resource "aws_secretsmanager_secret_version" "ad" {
  secret_id = aws_secretsmanager_secret.ad.id
  secret_string = jsonencode({
    username = "Admin"
    password = local.ad_admin_password
    domain   = local.ad_domain
  })
}

resource "aws_secretsmanager_secret" "opcenter_db" {
  name                    = "${var.name}/opcenter/db"
  description             = "Opcenter application database credentials for Helm and DB post-provisioning"
  recovery_window_in_days = 0
}

resource "aws_secretsmanager_secret_version" "opcenter_db" {
  secret_id = aws_secretsmanager_secret.opcenter_db.id
  secret_string = jsonencode({
    username = var.opcenter_db_username
    password = random_password.opcenter_db_user.result
    database = var.opcenter_db_name
  })
}
