module "vpc" {
  source  = "terraform-aws-modules/vpc/aws"
  version = "3.14.0"

  name = "${var.environment}-vpc"
  cidr = var.cidr_block

  azs             = var.availability_zones
  private_subnets = slice(var.subnet_cidr_blocks, 0, var.subnet_count / 2)
  public_subnets  = slice(var.subnet_cidr_blocks, var.subnet_count / 2, var.subnet_count)

  enable_nat_gateway = true
  single_nat_gateway = true

  tags = merge(
    {
      Environment = var.environment
      Terraform   = "true"
    },
    var.tags
  )
}

output "vpc_id" {
  value = module.vpc.vpc_id
}

output "public_subnets" {
  value = module.vpc.public_subnets
}

output "private_subnets" {
  value = module.vpc.private_subnets
}
