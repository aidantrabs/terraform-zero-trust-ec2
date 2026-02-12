module "networking" {
    source              = "./modules/networking"
    environment         = var.environment
    vpc_cidr            = var.vpc_cidr  
    availability_zone   = var.availability_zone
    private_subnet_cidr = var.private_subnet_cidr
}

module "ec2" {
    source                = "./modules/ec2" 
    environment           = var.environment
    vpc_id                = module.networking.vpc_id
    private_subnet_id     = module.networking.private_subnet_id
    instance_type         = var.instance_type
    vpc_cidr              = module.networking.vpc_cidr_block
}


