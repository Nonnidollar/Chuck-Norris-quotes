# Output the ECR repository URL
output "ecr_repository_url" {
  description = "The URL of the ECR repository"
  value       = aws_ecr_repository.app_repo.repository_url
}

# Output the EC2 instance public IP
output "ec2_public_ip" {
  description = "The public IP address of the EC2 instance"
  value       = aws_instance.app_instance_with_profile.public_ip
}

# Output the VPC ID
output "vpc_id" {
  description = "The ID of the created VPC"
  value       = aws_vpc.custom_vpc.id
}

# Output the EC2 Instance ID
output "ec2_instance_id" {
  description = "The ID of the created EC2 instance"
  value       = aws_instance.app_instance_with_profile.id
}

# Output the IAM role used by the EC2 instance
output "ec2_iam_role" {
  description = "The IAM role associated with the EC2 instance"
  value       = aws_iam_role.ecr_access_role.name
}

