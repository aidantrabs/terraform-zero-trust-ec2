output "vpc_id" {
    description = "ID of the VPC"
    value       = module.networking.vpc_id
}

output "private_subnet_id" {
    description = "ID of the private subnet"
    value       = module.networking.private_subnet_id
}

output "instance_id" {
    description = "ID of the instance"
    value       = module.ec2.instance_id
}
