#  Create Security Group for Bastion Host
resource "aws_security_group" "allow_ssh" {
  name        = "allow-ssh"
  description = "Allow SSH inbound from specific IP ranges"
  vpc_id      = module.network.vpc_id

  ingress {
    description = "SSH from specific IP"
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"] #ideally, this should be your office IP
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "${var.project_tag}-bastion-sg"
  }
}

#  Create Security Group for Private Instance
resource "aws_security_group" "allow_ssh_and_port_3000" {
  name        = "allow-ssh-and-port-3000"
  description = "Allow SSH and port 3000 inbound from VPC CIDR only"
  vpc_id      = module.network.vpc_id

  ingress {
    description     = "SSH from VPC"
    from_port       = 22
    to_port         = 22
    protocol        = "tcp"
    security_groups = [aws_security_group.allow_ssh.id]
  }

  ingress {
    description = "Port 3000 from VPC"
    from_port   = 3000
    to_port     = 3000
    protocol    = "tcp"
    cidr_blocks = [var.vpc_cidr]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "${var.project_tag}-app-sg"
  }
}
