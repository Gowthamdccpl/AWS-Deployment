module "vpc" {
  source = "./modules/vpc"

  name            = var.name
  cidr            = var.vpc_cidr
  azs             = var.azs
  private_subnets = var.private_subnets
  public_subnets  = var.public_subnets
  tags            = var.tags
}

module "ad" {
  source      = "./modules/ad"
  name        = "${var.name}.local"
  ad_password = local.ad_admin_password
  vpc_id      = module.vpc.vpc_id
  subnet_ids = [
    module.vpc.private_subnets[0],
    module.vpc.private_subnets[1]
  ]

  edition = "Standard"
  tags    = var.tags
}

module "fsx" {
  source = "./modules/fsx"
  vpc_id = module.vpc.vpc_id
  subnet_ids = [
    module.vpc.private_subnets[0],
    module.vpc.private_subnets[1]
  ]
  preferred_subnet = module.vpc.private_subnets[0]


  directory_id     = module.ad.directory_id
  throughput_mbps  = 32
  storage_capacity = 50
  tags             = var.tags

  depends_on = [module.ad]
}

module "rds" {
  source            = "./modules/rds"
  db_engine         = var.db_engine
  db_engine_version = var.db_engine_version
  db_instance_class = var.db_instance_class
  db_parameter      = var.db_parameter
  db_username       = var.db_username
  db_password       = local.rds_master_password
  vpc_id            = module.vpc.vpc_id
  subnet_ids        = module.vpc.private_subnets
  name              = var.name
  tags              = var.tags
}


module "eks" {
  source  = "terraform-aws-modules/eks/aws"
  version = "~> 21.3"

  name               = "${var.name}-eks"
  kubernetes_version = "1.35"

  vpc_id     = module.vpc.vpc_id
  subnet_ids = module.vpc.private_subnets

  enable_irsa                 = true
  create_cloudwatch_log_group = false

  timeouts = {
    create = "60m"
    update = "60m"
    delete = "60m"
  }

  eks_managed_node_groups = {
    linux-ng = {
      desired_size   = 1
      min_size       = 1
      max_size       = 1
      instance_types = ["t3.medium"]
      ami_type       = "AL2023_x86_64_STANDARD"
      labels = {
        lifecycle = "normal"
      }
      additional_iam_policies = [
        "arn:aws:iam::aws:policy/AmazonSSMManagedInstanceCore"
      ]
      timeouts = {
        create = "60m"
        update = "60m"
        delete = "60m"
      }

    }

    windows-ng = {
      desired_size   = 1
      min_size       = 1
      max_size       = 1
      instance_types = ["m5.xlarge"]
      ami_type       = "WINDOWS_CORE_2019_x86_64"
      timeouts = {
        create = "60m"
        update = "60m"
        delete = "60m"
      }
    }
  }

  tags = var.tags
}
