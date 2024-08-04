variable "environment" {
  description = "The environment where resources will be provisioned."
  type        = string
}

variable "region" {
  description = "The AWS region where resources will be provisioned."
  type        = string
  default     = "us-west-2"
}

variable "cidr_block" {
  description = "The CIDR block for the VPC"
  type        = string
}

variable "subnet_cidr_blocks" {
  description = "List of CIDR blocks for the subnets"
  type        = list(string)
}

variable "subnet_count" {
  description = "Number of subnets to create"
  type        = number
}

variable "availability_zones" {
  description = "List of availability zones"
  type        = list(string)
}

variable "tags" {
  description = "A map of tags to add to resources"
  type        = map(string)
}

variable "instance_type" {
  description = "Type of the instance"
  type        = string
}

variable "service_names" {
  description = "The list of service names for EC2 instances"
  type        = list(string)
}

variable "ec2_instance_prefix" {
  description = "Prefix for EC2 instance names"
  type        = string
}

variable "s3_bucket_prefix" {
  description = "Prefix for S3 bucket names"
  type        = string
}


variable "map_ec2_services" {
  description = "A map of service names with their configurations"
  type = map(object({
    tags = map(string)
  }))
  default = {
    "service1" = { tags = { "Role" = "web" } }
    "service2" = { tags = { "Role" = "db" } }
  }
}


// This variable is sensitive, so the value will not be printed
// Used Env vars to pass the secret and access key, example below
// export TF_VAR_secret_key="secret"
// export TF_VAR_access_key="access"
variable "secret_key" {
  description = "The secret"
  type        = string
  // Not printing the secret key
  sensitive = true
}

variable "access_key" {
  description = "The access key"
  type        = string
  sensitive   = true
}