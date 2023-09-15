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

# Subnet creation -private



resource "aws_subnet" "private" {
  count                   = 3
  vpc_id                  = aws_vpc.vpc.id
  cidr_block              = cidrsubnet(var.vpc_cidr_block, 3, count.index + 3)
  map_public_ip_on_launch = false
  availability_zone       = data.aws_availability_zones.available.names[count.index]
  tags = {
    Name    = "${var.project_name}-${var.project_environment}-private${count.index}"
    project = var.project_name
    Env     = var.project_environment
  }
}

# Elastic IP creation


resource "aws_eip" "nat" {
  domain = "vpc"
  tags = {
    Name    = "${var.project_name}-${var.project_environment}-Natgw"
    project = var.project_name
    Env     = var.project_environment
  }
}


# NAT Gateway creation




resource "aws_nat_gateway" "nat" {
  allocation_id = aws_eip.nat.id
  subnet_id     = aws_subnet.public[1].id

  tags = {
    Name    = "${var.project_name}-${var.project_environment}"
    project = var.project_name
    Env     = var.project_environment
  }

  # To ensure proper ordering, it is recommended to add an explicit dependency
  # on the Internet Gateway for the VPC.
  depends_on = [aws_internet_gateway.igw]
}


# Route table creation - Public



resource "aws_route_table" "public" {
  vpc_id = aws_vpc.vpc.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.igw.id
  }

  tags = {
    Name    = "${var.project_name}-${var.project_environment}-public"
    project = var.project_name
    Env     = var.project_environment
  }
}

# Route table creation - Private




resource "aws_route_table" "private" {
  vpc_id = aws_vpc.vpc.id

  route {
    cidr_block     = "0.0.0.0/0"
    nat_gateway_id = aws_nat_gateway.nat.id
  }

  tags = {
    Name    = "${var.project_name}-${var.project_environment}-private"
    project = var.project_name
    Env     = var.project_environment
  }
}


