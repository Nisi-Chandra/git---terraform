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

# Subnet creation -public


resource "aws_subnet" "public" {
  count                   = 3
  vpc_id                  = aws_vpc.vpc.id
  cidr_block              = cidrsubnet(var.vpc_cidr_block, 3, count.index)
  map_public_ip_on_launch = true
  availability_zone       = data.aws_availability_zones.available.names[count.index]
  tags = {
    Name    = "${var.project_name}-${var.project_environment}-public${count.index + 1}"
    project = var.project_name
    Env     = var.project_environment
  }
}


