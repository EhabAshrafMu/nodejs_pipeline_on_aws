# 3. Create Public Subnet
resource "aws_subnet" "public_subnet" {
  vpc_id                  = aws_vpc.node_js_vpc.id
  cidr_block              = var.public_subnet_cidr
  map_public_ip_on_launch = true
  availability_zone       = "${var.region}a"

  tags = {
    Name = "${var.project_tag}-public"
  }
}

# 4. Create Private Subnet
resource "aws_subnet" "private_subnet" {
  vpc_id            = aws_vpc.node_js_vpc.id
  cidr_block        = var.private_subnet_cidr
  availability_zone = "${var.region}b"

  tags = {
    Name = "${var.project_tag}-private"
  }
}
