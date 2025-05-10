
#  Create EC2 (Bastion Host) in Public Subnet
resource "aws_instance" "bastion_host" {
  ami                         = data.aws_ami.ubuntu.id
  instance_type               = var.instance_type
  subnet_id                   = module.network.public_subnet_id
  vpc_security_group_ids      = [aws_security_group.allow_ssh.id]
  key_name                    = aws_key_pair.nodejs_key.key_name
  associate_public_ip_address = true
  tags = {
    Name = "${var.project_tag}-bastion"
  }

  depends_on = [module.network.my_internet_gateway]

  provisioner "local-exec" {
    command = "echo ${self.private_ip}"
  }
}

# 12. Create EC2 (Private Host) in Private Subnet
resource "aws_instance" "application" {
  ami                    = data.aws_ami.ubuntu.id
  instance_type          = var.instance_type
  subnet_id              = module.network.private_subnet_id
  vpc_security_group_ids = [aws_security_group.allow_ssh_and_port_3000.id]
  key_name               = aws_key_pair.nodejs_key.key_name

  tags = {
    Name = "${var.project_tag}-app"
  }
}
