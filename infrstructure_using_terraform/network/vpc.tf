# Create VPC
resource "aws_vpc" "node_js_vpc" {
  cidr_block           = var.vpc_cidr
  enable_dns_hostnames = true
  enable_dns_support   = true

  tags = {
    Name = var.project_tag
  }
}


