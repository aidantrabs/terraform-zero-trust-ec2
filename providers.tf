provider "aws" {
    region = var.aws_region
    default_tags {
        tags = {
            Project     = "terraform-zero-trust-ec2"
            ManagedBy   = "terraform"
            Environment = var.environment
        }
    }
}
