# Security Group for EKS nodes (will be the source for other SGs)
resource "aws_security_group" "eks_nodes_sg" {
  name        = "${var.project}-eks-nodes-sg"
  description = "Security group for EKS worker nodes"
  vpc_id      = module.vpc.vpc_id
  tags        = merge(var.tags, { Name = "${var.project}-eks-nodes-sg" })
}

# RDS SG
resource "aws_security_group" "rds_sg" {
  name        = "${var.project}-rds-sg"
  vpc_id      = module.vpc.vpc_id
  description = "Allow SQL Server from EKS nodes"
  ingress {
    description     = "SQL Server"
    from_port       = 1433
    to_port         = 1433
    protocol        = "tcp"
    security_groups = [aws_security_group.eks_nodes_sg.id]
  }
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
  tags = merge(var.tags, { Name = "${var.project}-rds-sg" })
}

# License Server SG
resource "aws_security_group" "license_sg" {
  name   = "${var.project}-license-sg"
  vpc_id = module.vpc.vpc_id
  ingress {
    from_port       = 29000
    to_port         = 29000
    protocol        = "tcp"
    security_groups = [aws_security_group.eks_nodes_sg.id]
    description     = "Siemens License Server port"
  }
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
  tags = merge(var.tags, { Name = "${var.project}-license-sg" })
}

# LDAP/AD SG (allow LDAPS)
resource "aws_security_group" "ldap_sg" {
  name   = "${var.project}-ldap-sg"
  vpc_id = module.vpc.vpc_id
  ingress {
    from_port       = 636
    to_port         = 636
    protocol        = "tcp"
    security_groups = [aws_security_group.eks_nodes_sg.id]
  }
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
  tags = merge(var.tags, { Name = "${var.project}-ldap-sg" })
}

# FSx SG (SMB)
resource "aws_security_group" "fsx_sg" {
  name   = "${var.project}-fsx-sg"
  vpc_id = module.vpc.vpc_id
  ingress {
    from_port       = 445
    to_port         = 445
    protocol        = "tcp"
    security_groups = [aws_security_group.eks_nodes_sg.id]
  }
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
  tags = merge(var.tags, { Name = "${var.project}-fsx-sg" })
}
