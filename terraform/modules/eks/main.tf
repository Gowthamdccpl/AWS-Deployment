module "eks" {
  source  = "terraform-aws-modules/eks/aws"
  version = "~> 21.3"

  cluster_name                    = var.name
  cluster_version                 = var.cluster_version # null -> module picks a sane default; set explicit for control
  vpc_id                          = var.vpc_id
  subnet_ids                      = var.private_subnet_ids
  enable_irsa                     = var.enable_irsa
  cluster_endpoint_public_access  = true
  cluster_endpoint_private_access = true

  eks_managed_node_groups = var.eks_managed_node_groups

  tags = var.tags
}

