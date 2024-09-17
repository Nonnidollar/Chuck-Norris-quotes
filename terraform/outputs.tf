
# Output the EC2 instance public IP
output "ec2_public_ip" {
  description = "The public IP address of the EC2 instance"
  value       = aws_instance.app_instance.public_ip
}

# Output the VPC ID
output "vpc_id" {
  description = "The ID of the created VPC"
  value       = aws_vpc.custom_vpc.id
}

# Output the EC2 Instance ID
output "ec2_instance_id" {
  description = "The ID of the created EC2 instance"
  value       = aws_instance.app_instance.public_ip
}

# Output the EC2 Public DNS ID
output "ec2_public_dns" {
  description = "The Public DNS of the created EC2 instance"
  value       = aws_instance.app_instance.public_dns
}



