data "aws_ami" "amazon_linux" {
    most_recent = true
    owners      = [var.ami_owner]
    
    filter {
        name   = "name"
        values = [var.ami_name_filter]
    }

    filter {
        name   = "virtualization-type"
        values = ["hvm"]
    }

    filter {
        name   = "architecture"
        values = ["x86_64"]
    }
}

resource "aws_iam_role" "ec2_iam_role" {
    name = "${var.environment}-ec2-iam-role"
    
    assume_role_policy = jsonencode({
        "Version": "2012-10-17",
        "Statement": [{
            "Action": "sts:AssumeRole",
            "Effect": "Allow",
            "Principal": { "Service": "ec2.amazonaws.com" }
        }]
    })

    tags = {
        Name        = "${var.environment}-ec2-iam-role"
        Environment = var.environment 
    }
}

resource "aws_iam_role_policy_attachment" "ec2_policy_attachment" {
    role      = aws_iam_role.ec2_iam_role.name
    policy_arn = "arn:aws:iam::aws:policy/AmazonSSMManagedInstanceCore"
}

resource "aws_iam_instance_profile" "ec2_instance_profile" {
    name = "${var.environment}-ec2-instance-profile" 
    role = aws_iam_role.ec2_iam_role.name
}

resource "aws_security_group" "ec2_security_group" {
    description = "Security group for zero-trust EC2"
    vpc_id      = var.vpc_id
}

resource "aws_vpc_security_group_egress_rule" "ec2_security_group_egress" {
    name              = "${var.environment}-ec2-security-group-egress"
    security_group_id = aws_security_group.ec2_security_group.id
   
    cidr_ipv4         = "10.0.0.0/16";
    from_port         = 443 
    ip_protocol       = "tcp"
    to_port           = 443
}

resource "aws_instance" "ec2_instance" {
    ami                         = data.aws_ami.amazon_linux.id
    instance_type               = var.instance_type   
    subnet_id                   = var.private_subnet_id
    vpc_security_group_ids      = [aws_security_group.ec2_security_group.id]
    iam_instance_profile        = aws_iam_instance_profile.ec2_instance_profile.name

    associate_public_ip_address = false

    root_block_device {
        volume_type           = "gp3"
        volume_size           = 8
        encrypted             = true
        delete_on_termination = true 
    }

    metadata_options {
        http_tokens                 = "required"
        http_endpoint               = "enabled"
        http_put_response_hop_limit = 1
    } 

    tags = {
        Name        = "${var.environment}-ec2-instance"
        Environment = "${var.environment}"
    }
}
