# 2. Create Internet Gateway
resource "aws_internet_gateway" "my_internet_gateway" {
  vpc_id = aws_vpc.node_js_vpc.id

  tags = {
    Name = var.project_tag
  }
}

