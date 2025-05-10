# Generate a new key pair
resource "tls_private_key" "this" {
  algorithm = "RSA"
  rsa_bits  = 4096
}

# Store private key in SSM Parameter Store (SecureString)
resource "aws_ssm_parameter" "private_key" {
  name        = "/${var.project_tag}/ssh-private-key"
  description = "SSH private key for ${var.project_tag} EC2 instances"
  type        = "SecureString"
  value       = tls_private_key.this.private_key_pem

  tags = {
    Name = var.project_tag
  }
}

# Create AWS key pair using the public key
resource "aws_key_pair" "nodejs_key" {
  key_name   = "${var.project_tag}-key"
  public_key = tls_private_key.this.public_key_openssh

  tags = {
    Name = var.project_tag
  }
}
