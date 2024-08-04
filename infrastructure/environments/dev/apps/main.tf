locals {
  aws_region = var.region
  extra_tags = {
    "Terraform"   = "true"
    "Environment" = "test"
  }
}

#tfsec:ignore:aws-ec2-require-vpc-flow-logs-for-all-vpcs
module "vpc" {
  source = "../../../modules/vpc"

  cidr_block         = var.cidr_block
  subnet_cidr_blocks = var.subnet_cidr_blocks
  subnet_count       = var.subnet_count
  availability_zones = var.availability_zones
  environment        = var.environment
  tags               = var.tags
}

module "security_group" {
  source      = "../../../resources/security-group"
  vpc_id      = module.vpc.vpc_id
  environment = var.environment
}

module "test_s3_bucket" {
  source      = "../../../resources/s3" # Relative path to the S3 module
  environment = var.environment
}

module "aws_instance_modul" {
  source = "../../../resources/ec2" # Relative path to the EC2 module

  environment = var.environment
  # Pass any required variables (env variables)
  service_names     = var.service_names
  subnet_id         = element(module.vpc.public_subnets, 0) # Using the first public subnet
  vpc_id            = module.vpc.vpc_id
  security_group_id = module.security_group.security_group_id
  # Pass any required variables (if applicable)
  map_public_ip_on_launch = true
  instance_type           = "t2.micro"
}