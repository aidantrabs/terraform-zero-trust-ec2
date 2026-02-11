variable "environment" {
    type        = string
    description = "Environment name for resource tagging"
}

variable "vpc_id" {
    type         = string
    description  = "ID of the VPC"
}

variable "vpc_cidr" {
    type        = string
    description = "CIDR block for the VPC"
}

variable "instance_type" {
    type        = string
    description = "EC2 instance type"
    default     = "t3.micro"
}

variable "private_subnet_id" {
    type        = string
    description = "ID of the private subnet"
}

variable "ami_name_filter" {
    type        = string
    description = "AMI name filter pattern"
    default     = "al2023-ami-*-x86_64"
}

variable "ami_owner" {
    type        = string
    description = "AMI owner account ID or alias"
    default     = "amazon"
}

