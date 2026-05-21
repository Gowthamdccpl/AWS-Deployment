resource "aws_security_group" "fsx" {
  name        = "${var.vpc_id}-fsx-sg"
  description = "FSx for Windows access"
  vpc_id      = var.vpc_id

  ingress {
    from_port   = 445
    to_port     = 445
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"] # tighten to your client ranges
    description = "SMB"
  }

  # AD/DC communication ports – tighten as needed
  ingress {
    from_port   = 1024
    to_port     = 65535
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
    description = "Ephemeral for AD"
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = var.tags
}

resource "aws_fsx_windows_file_system" "this" {
  storage_capacity    = var.storage_capacity
  subnet_ids          = var.subnet_ids
  preferred_subnet_id = var.preferred_subnet
  throughput_capacity = var.throughput_mbps

  active_directory_id = var.directory_id

  security_group_ids = [aws_security_group.fsx.id]

  deployment_type                   = "MULTI_AZ_1" # latest best practice; switch to SINGLE_AZ_2 if desired
  automatic_backup_retention_days   = 7
  daily_automatic_backup_start_time = "03:00"
  weekly_maintenance_start_time     = "1:05:00" # Monday 05:00 UTC

  timeouts {
    create = "60m"
    update = "60m"
    delete = "60m"
  }

  tags = var.tags
}
