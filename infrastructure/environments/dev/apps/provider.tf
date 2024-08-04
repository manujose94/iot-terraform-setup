terraform {
  required_version = ">= 1.3.7"
  required_providers {
    aws = {
      source  = "registry.terraform.io/hashicorp/aws"
      version = "~> 3.0"
    }
  }
}

# Aws
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