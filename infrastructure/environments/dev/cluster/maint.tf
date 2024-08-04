# Define resources for each environment
locals {
  aws_region = var.region
  extra_tags = {
    "Terraform"   = "true"
    "Environment" = var.environment
  }
}

module "dev_eks" {
  source = "../../../modules/eks"
  environment = var.environment
}

provider "aws" {
    alias     = "real_aws"
    region =    var.region
    access_key = var.access_key
    secret_key = var.secret_key
    // Inform Terraform to use the shared credentials file
    //shared_credentials_file = "~/.aws/credentials"
    //shared_config_file = ["~/.aws/config"]
    profile ="personal"
}