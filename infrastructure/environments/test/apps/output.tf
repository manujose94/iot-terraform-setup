output "instance_public_ips" {
  value = module.aws_instance_modul.instance_public_ips
}

output "instance_private_ips" {
  value = module.aws_instance_modul.instance_private_ips
}

output "instance_info" {
  value = {
    for instance_name in var.service_names :
    instance_name => {
      name = "${var.ec2_instance_prefix}-${var.environment}-${instance_name}"
      tags = {
        "Name"        = "${var.ec2_instance_prefix}-${var.environment}-${instance_name}"
        "Environment" = var.environment
      }
    }
  }
}

output "vpc_id" {
  value = module.vpc.vpc_id
}

output "public_subnet_ids" {
  value = module.vpc.public_subnets
}

output "private_subnet_ids" {
  value = module.vpc.private_subnets
}