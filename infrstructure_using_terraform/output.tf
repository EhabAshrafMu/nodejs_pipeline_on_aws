# Outputs
output "vpc_id" {
  description = "ID of the VPC"
  value       = module.network.vpc_id
}

output "bastion_public_ip" {
  description = "Public IP of the bastion host"
  value       = aws_instance.bastion_host.public_ip
}

output "application_private_ip" {
  description = "Private IP of the application server"
  value       = aws_instance.application.private_ip
}

output "ssm_parameter_name" {
  description = "The name of the SSM parameter storing the private key"
  value       = aws_ssm_parameter.private_key.name
}

output "ssh_key_instructions" {
  description = "Command to retrieve the private key from SSM Parameter Store"
  value       = "aws ssm get-parameter --name ${aws_ssm_parameter.private_key.name} --with-decryption --query Parameter.Value --output text > private_key.pem && chmod 400 private_key.pem"
}
