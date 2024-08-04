variable "environment" {
  description = "The environment where resources will be provisioned."
  type        = string
}

variable "ec2_instance_prefix" {
  description = "Prefix for EC2 instance names"
  type = string
  default = "test-cloudiot"
}

variable "instance_type" {
  description = "The instance type for the EC2 instance."
  type = string
  default = "t2.micro"
}

variable "service_names" {
  description = "The list of service names for EC2 instances"
  type        = list(string)
  default     = ["default-ec2-service"]  # Default value for the service name
}


variable "subnet_id" {
  description = "The subnet ID where the instance will be deployed"
  type        = string
}

variable "vpc_id" {
  description = "The VPC ID where the instance will be deployed"
  type        = string
}

variable "security_group_id" {
  description = "The security group ID to assign to the instance"
  type        = string
}

variable "map_public_ip_on_launch" {
  description = "Map public IP on launch"
  type        = bool
  default     = false
}