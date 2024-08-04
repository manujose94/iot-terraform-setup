

### Adjust EC2 Module
#### `test/variables.tf`

Define `service_names` as a map of objects:

```hcl
variable "service_names" {
  description = "A map of service names with their configurations"
  type        = map(object({
    tags = map(string)
  }))
  default = {
    "service1" = { tags = { "Role" = "web" } }
    "service2" = { tags = { "Role" = "db" } }
  }
}
```

#### `resources/ec2/main.tf`

Update the resource definition to iterate over the map:

```hcl
resource "aws_instance" "base_instance" {
  for_each = var.service_names

  ami                    = "ami-0123456789abcdef0"
  instance_type          = var.instance_type
  subnet_id              = var.subnet_id
  vpc_security_group_ids = [var.security_group_id]

  associate_public_ip_address = var.map_public_ip_on_launch

  tags = merge(
    {
      Name = "${var.ec2_instance_prefix}-${var.environment}-${each.key}"
      Environment = var.environment
    },
    each.value.tags
  )
}
```

#### `test/output.tf`

Update the `output "instance_info"` to reflect the new structure:

```hcl
output "instance_info" {
  value = {
    for instance_name, instance_config in var.service_names :
    instance_name => {
      name = "${var.ec2_instance_prefix}-${var.environment}-${instance_name}"
      tags = merge(
        {
          "Name"        = "${var.ec2_instance_prefix}-${var.environment}-${instance_name}"
          "Environment" = var.environment
        },
        instance_config.tags
      )
    }
  }
}
```