resource "aws_directory_service_directory" "ad" {
  name     = var.name
  password = var.ad_password
  edition  = "Standard" # or "Enterprise"
  type     = "MicrosoftAD"
  vpc_settings {
    vpc_id     = var.vpc_id
    subnet_ids = var.subnet_ids
  }

  timeouts {
    create = "60m"
    update = "60m"
    delete = "60m"
  }

  tags = var.tags
}
