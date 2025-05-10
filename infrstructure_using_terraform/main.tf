#explicit the provider
provider "aws" {
  region = var.region
}

# import network module
module "network" {
  source              = "./network"
  region              = var.region
  vpc_cidr            = var.vpc_cidr
  public_subnet_cidr  = var.public_subnet_cidr
  private_subnet_cidr = var.private_subnet_cidr
  project_tag         = var.project_tag
}
