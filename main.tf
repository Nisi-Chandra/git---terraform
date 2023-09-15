# VPC Creation


resource "aws_vpc" "vpc" {
  cidr_block           = var.vpc_cidr_block
  instance_tenancy     = "default"
  enable_dns_hostnames = true
  tags = {
    Name    = "${var.project_name}-${var.project_environment}"
    project = var.project_name
    Env     = var.project_environment
  }
}



# Internet gateway Creation


resource "aws_internet_gateway" "igw" {
  vpc_id = aws_vpc.vpc.id

  tags = {
    Name    = "${var.project_name}-${var.project_environment}"
    project = var.project_name
    Env     = var.project_environment
  }
}

