variable "environment" {
    type        = string
    description = "Environment name for resource tagging"
}

variable "vpc_cidr" {
    type        = string
    description = "CIDR block for the VPC"
}

variable "availability_zone" {
    type = string
    description = "Availability zone"
}

variable "private_subnet_cidr" {
    type        = string
    description = "CIDR block for the private subnet"
}

