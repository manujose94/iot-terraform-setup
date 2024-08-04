#  To access the output values from the instances created inside the module
#  Define the outputs within the module and then reference those outputs in the root module
output "instance_public_ips" {
  value = { for instance in aws_instance.base_instance : instance.id => instance.public_ip }
}

output "instance_private_ips" {
  value = { for instance in aws_instance.base_instance : instance.id => instance.private_ip }
}

output "instance_info" {
  value = {
    for instance in aws_instance.base_instance :
    instance.id => {
      id        = instance.id
      public_ip = instance.public_ip
      private_ip = instance.private_ip
      name      = instance.tags["Name"]
      tags = instance.tags
    }
  }
}