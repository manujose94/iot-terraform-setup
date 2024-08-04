
resource "aws_instance" "base_instance" {
  for_each = { for idx, val in var.service_names : val => val }
  ami             = "ami-0123456789abcdef0"
  instance_type          = var.instance_type
  subnet_id              = var.subnet_id
  vpc_security_group_ids = [var.security_group_id]

  associate_public_ip_address = var.map_public_ip_on_launch

  tags = {
    Name = "${var.ec2_instance_prefix}-${var.environment}-${each.key}"
    Environment = var.environment
    Service     = each.value
  }
}