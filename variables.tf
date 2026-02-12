variable "environment" {
    type        = string
    description = "Environment name (dev, staging, prod)"
    default     = "dev"
}

variable "aws_region" {
    type        = string
    description = "AWS region for deployment"
    default     = "us-east-1"
}

variable "vpc_cidr" {
    type        = string
    description = "CIDR block for the VPC"
    default     = "10.0.0.0/16"
}

variable "instance_type" {
    type        = string
    description = "EC2 instance type"
    default     = "t3.micro"
} 

variable "availability_zone" {
    type        = string
    description = "Availability zone for the EC2 instance"
    default     = "us-east-1a"
}

variable "private_subnet_cidr" {
    type        = string
    description = "CIDR for the private subnet"
    default     = "10.0.1.0/24"
}
