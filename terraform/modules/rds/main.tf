data "aws_rds_engine_version" "selected" {
  engine                 = var.db_engine
  parameter_group_family = var.db_parameter
  default_only           = true
}

resource "aws_db_subnet_group" "this" {
  name_prefix = "${var.name}-db-subnets-"
  subnet_ids  = var.subnet_ids
  tags        = var.tags
}

resource "aws_security_group" "db" {
  name        = "${var.name}-db-sg"
  description = "RDS access"
  vpc_id      = var.vpc_id

  ingress {
    from_port   = 5432
    to_port     = 5432
    protocol    = "tcp"
    cidr_blocks = ["10.0.0.0/16"] # tighten to app SGs or specific CIDRs
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = var.tags
}


resource "aws_db_instance" "sqlserver" {
  identifier          = "${var.name}-sql"
  instance_class      = var.db_instance_class
  engine              = "sqlserver-ex"
  license_model       = "license-included"
  username            = var.db_username
  password            = var.db_password
  allocated_storage   = 50
  storage_type        = "gp2"
  multi_az            = false
  skip_final_snapshot = true

  db_subnet_group_name   = aws_db_subnet_group.this.name
  vpc_security_group_ids = [aws_security_group.db.id]

  tags = var.tags
}
