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

# Route table association - Public



resource "aws_route_table_association" "public" {
  count          = 3
  subnet_id      = aws_subnet.public[count.index].id
  route_table_id = aws_route_table.public.id
}


# Route table association - Private



resource "aws_route_table_association" "private" {
  count          = 3
  subnet_id      = aws_subnet.private[count.index].id
  route_table_id = aws_route_table.private.id
}

resource "aws_security_group" "bastion" {
  name_prefix = "${var.project_name}-${var.project_environment}-bastion-"
  description = "bastion security group"
  vpc_id      = aws_vpc.vpc.id

  ingress {
    from_port        = 22
    to_port          = 22
    protocol         = "tcp"
    cidr_blocks      = ["0.0.0.0/0"]
    ipv6_cidr_blocks = ["::/0"]
  }

  egress {
    from_port        = 0
    to_port          = 0
    protocol         = "-1"
    cidr_blocks      = ["0.0.0.0/0"]
    ipv6_cidr_blocks = ["::/0"]
  }

  tags = {
    Name    = "${var.project_name}-${var.project_environment}-bastion"
    project = var.project_name
    Env     = var.project_environment
  }

  lifecycle {
    create_before_destroy = true
  }
}

###########Front-end-security group####


resource "aws_security_group" "frontend" {
  name_prefix = "${var.project_name}-${var.project_environment}-frontend-"
  vpc_id      = aws_vpc.vpc.id

  ingress {
    from_port       = 22
    to_port         = 22
    protocol        = "tcp"
    security_groups = [aws_security_group.bastion.id]
  }

  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port        = 0
    to_port          = 0
    protocol         = "-1"
    cidr_blocks      = ["0.0.0.0/0"]
    ipv6_cidr_blocks = ["::/0"]
  }

  tags = {
    Name    = "${var.project_name}-${var.project_environment}-frontend-"
    project = var.project_name
    Env     = var.project_environment
  }

  lifecycle {
    create_before_destroy = true
  }
}


########Back end-security group######


resource "aws_security_group" "backend" {
  name_prefix = "${var.project_name}-${var.project_environment}-backend-"
  vpc_id      = aws_vpc.vpc.id

  ingress {
    from_port       = 22
    to_port         = 22
    protocol        = "tcp"
    security_groups = [aws_security_group.bastion.id]
  }

  ingress {
    from_port       = 3306
    to_port         = 3306
    protocol        = "tcp"
    security_groups = [aws_security_group.frontend.id]
  }


  egress {
    from_port        = 0
    to_port          = 0
    protocol         = "-1"
    cidr_blocks      = ["0.0.0.0/0"]
    ipv6_cidr_blocks = ["::/0"]
  }

  tags = {
    Name    = "${var.project_name}-${var.project_environment}-backend-"
    project = var.project_name
    Env     = var.project_environment
  }

  lifecycle {
    create_before_destroy = true
  }
}

