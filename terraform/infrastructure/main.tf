module "vpc" {
  source              = "./modules/vpc"
  environment         = var.environment
  vpc_cidr            = "10.0.0.0/16"
  public_subnet_cidr  = "10.0.1.0/24"
  private_subnet_cidr = "10.0.2.0/24"
}

module "ec2" {
  source            = "./modules/ec2"
  environment       = var.environment
  vpc_id            = module.vpc.vpc_id
  public_subnet_id  = module.vpc.public_subnet_id
  private_subnet_id = module.vpc.private_subnet_id
  instance_type     = "t2.micro"
  my_ip             = "0.0.0.0/0"
}
