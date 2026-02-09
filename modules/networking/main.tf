data "aws_region" "current" {}

resource "aws_vpc" "main" {
    cidr_block           = var.vpc_cidr
    enable_dns_hostnames = true
    enable_dns_support   = true

    tags = {
        Name        = "${var.environment}-vpc"
        Environment = var.environment
    }
}

resource "aws_subnet" "private_subnet" {
    vpc_id            = aws_vpc.main.id
    cidr_block        = var.private_subnet_cidr
    availability_zone = var.availability_zone

    tags = {
        Name        = "${var.environment}-private-subnet"
        Environment = var.environment
        Tier        = "private"
    }
}

resource "aws_security_group" "allow_tls" {
    name        = "${var.environment}-allow-tls"
    description = "Allow TLS inbound traffic"
    vpc_id      = aws_vpc.main.id

    tags = {
        Name        = "${var.environment}-ec2-sg"
        Environment = var.environment
    }
}

resource "aws_vpc_security_group_ingress_rule" "allow_tls_ipv4" {
    security_group_id = aws_security_group.allow_tls.id
    cidr_ipv4         = aws_vpc.main.cidr_block
    from_port         = 443
    ip_protocol       = "tcp"
    to_port           = 443
}

resource "aws_vpc_endpoint" "vpc_ssm_api_endpoint" {
    vpc_id              = aws_vpc.main.id
    service_name        = "com.amazonaws.${data.aws_region.current.name}.ssm" 
    vpc_endpoint_type   = "Interface"
    subnet_ids          = [ aws_subnet.private_subnet.id ]
    security_group_ids  = [ aws_security_group.allow_tls.id ]
    private_dns_enabled = true
}

resource "aws_vpc_endpoint" "vpc_session_channel_endpoint" {
    vpc_id              = aws_vpc.main.id
    service_name        = "com.amazonaws.${data.aws_region.current.name}.ssmmessages" 
    vpc_endpoint_type   = "Interface"
    subnet_ids          = [ aws_subnet.private_subnet.id ]
    security_group_ids  = [ aws_security_group.allow_tls.id ]
    private_dns_enabled = true
}

resource "aws_vpc_endpoint" "vpc_message_delivery_ec2_endpoint" {
    vpc_id              = aws_vpc.main.id
    service_name        = "com.amazonaws.${data.aws_region.current.name}.ec2messages" 
    vpc_endpoint_type   = "Interface"
    subnet_ids          = [ aws_subnet.private_subnet.id ]
    security_group_ids  = [ aws_security_group.allow_tls.id ]
    private_dns_enabled = true
}
