output "instance_id" {
    description = "Instance ID of the EC2 instance"
    value       = aws_instance.ec2_instance.id
}

output "security_group_id" {
    description = "Security group ID for the EC2 instance"
    value       = aws_security_group.ec2_security_group.id
}
