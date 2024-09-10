# Define the AWS provider
provider "aws" {
  region = "us-east-1"  # Change as per your region
}

# Create a VPC
resource "aws_vpc" "custom_vpc" {
  cidr_block = "10.0.0.0/16"
  tags = {
    Name = "CustomVPC"
  }
}

# Create an Internet Gateway
resource "aws_internet_gateway" "internet_gw" {
  vpc_id = aws_vpc.custom_vpc.id
  tags = {
    Name = "InternetGateway"
  }
}

# Create public subnet
resource "aws_subnet" "public_subnet" {
  vpc_id                  = aws_vpc.custom_vpc.id
  cidr_block              = "10.0.1.0/24"
  map_public_ip_on_launch = true
  availability_zone       = "us-east-1a"  # Update based on your region

  tags = {
    Name = "PublicSubnet"
  }
}

# Create Route Table
resource "aws_route_table" "public_route_table" {
  vpc_id = aws_vpc.custom_vpc.id
  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.internet_gw.id
  }
}

# Associate Route Table with Public Subnet
resource "aws_route_table_association" "public_route_association" {
  subnet_id      = aws_subnet.public_subnet.id
  route_table_id = aws_route_table.public_route_table.id
}

# Create Security Group for EC2 Instance
resource "aws_security_group" "app_sg" {
  vpc_id = aws_vpc.custom_vpc.id

  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    from_port   = 3000
    to_port     = 3000
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "AppSecurityGroup"
  }
}

# Create an ECR repository
resource "aws_ecr_repository" "app_repo" {
  name                 = "my-app-repo"
  image_tag_mutability = "MUTABLE"
  image_scanning_configuration {
    scan_on_push = true
  }

  tags = {
    Name = "AppECRRepository"
  }
}

# IAM Role for ECR access (for EC2 or CI/CD)
resource "aws_iam_role" "ecr_access_role" {
  name = "EC2ECRAccessRole"
  assume_role_policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Action": "sts:AssumeRole",
      "Effect": "Allow",
      "Principal": {
        "Service": "ec2.amazonaws.com"
      }
    }
  ]
}
EOF
}

# Attach policy to allow EC2 to interact with ECR
resource "aws_iam_role_policy" "ecr_access_policy" {
  role = aws_iam_role.ecr_access_role.id

  policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect": "Allow",
      "Action": [
        "ecr:GetDownloadUrlForLayer",
        "ecr:BatchGetImage",
        "ecr:BatchCheckLayerAvailability",
        "ecr:PutImage",
        "ecr:InitiateLayerUpload",
        "ecr:UploadLayerPart",
        "ecr:CompleteLayerUpload"
      ],
      "Resource": "${aws_ecr_repository.app_repo.arn}"
    },
    {
      "Effect": "Allow",
      "Action": "ecr:ListImages",
      "Resource": "*"
    }
  ]
}
EOF
}

# Attach the IAM role to EC2 instance
resource "aws_iam_instance_profile" "instance_profile" {
  name = "EC2InstanceProfile"
  role = aws_iam_role.ecr_access_role.name
}

# Create EC2 Instance with IAM Role
resource "aws_instance" "app_instance_with_profile" {
  ami                         = "ami-0a5c3558529277641"  # Amazon Linux 2 AMI ID (update based on your region)
  instance_type               = "t2.micro"
  subnet_id                   = aws_subnet.public_subnet.id
  vpc_security_group_ids       = [aws_security_group.app_sg.id]
  key_name                    = aws_key_pair.my_key_pair.key_name
  iam_instance_profile        = aws_iam_instance_profile.instance_profile.name

  tags = {
    Name = "NodeJS-EC2"
  }

  # User data to install Docker and run your app
  user_data = <<-EOF
              #!/bin/bash
              sudo yum update -y
              sudo yum install docker -y
              sudo service docker start
              sudo usermod -a -G docker ec2-user
              docker run -d -p 3000:3000 your-docker-image
              EOF

  associate_public_ip_address = true
}
