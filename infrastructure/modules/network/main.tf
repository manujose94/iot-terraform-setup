module "vpc-cluster" {
  source = "terraform-aws-modules/vpc/aws"
  name   = "cloudiot-vpc"
  cidr   = "10.0.0.0/16"
  // Allow High-availability across 3 AZs (production ready)   
  azs             = ["us-east-1a", "us-east-1b", "us-east-1d"]
  private_subnets = ["0.0.1.0/24", "10.0.2.0/24", "10.0.3.0/24"]
  public_subnets  = ["10.0.4.0/24", "10.0.5.0/24", "10.0.6.0/24"]
  // public_subnet with internaet access
  create_igw = true
  // private_subnet with internaet access
  // Allow internet access to private subnet via NAT Gateway
  // Allow update Nodes in private subnet
  enable_nat_gateway = true
  // One NAT Gateway per AZ
  single_nat_gateway = true
  //INFO: Pro Tip: Use "enable_nat_gateway = false" and "enable_vpn_gateway = true" to enable VPN Gateway. Also one gateway per AZ
  // Enable DNS Hostnames in the VPC
  enable_dns_hostnames = true
  // Enable DNS Support in the VPC
  enable_dns_support = true
  // Enable ClassicLink for VPC
  enable_classiclink = false
  // Enable ClassicLink DNS Support for VPC
  enable_classiclink_dns_support = false

  tags = {
    "Terraform"   = "true"
    "Environment" = "dev"
  }
}