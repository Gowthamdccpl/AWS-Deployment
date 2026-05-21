module "vpc" {
  source  = "terraform-aws-modules/vpc/aws"
  version = "6.4.0"

  name                    = var.name
  cidr                    = var.cidr
  azs                     = var.azs
  private_subnets         = var.private_subnets
  public_subnets          = var.public_subnets
  enable_nat_gateway      = true
  single_nat_gateway      = true
  enable_dns_hostnames    = true
  enable_dns_support      = true
  map_public_ip_on_launch = true

  tags = var.tags
}

