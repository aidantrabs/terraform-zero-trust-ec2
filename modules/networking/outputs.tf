output "vpc_id" {
    description = "ID of the VPC"
    value       = aws_vpc.main.id 
}

output "vpc_cidr_block" {
    description = "CIDR block of the VPC"
    value       = aws_vpc.main.cidr_block
}

output "private_subnet_id" {
    description = "ID of the private subent"
    value = aws_subnet.private_subnet.id
}

