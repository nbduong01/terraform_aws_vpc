provider "aws" {
  region = "ap-south-1"
}

# create VPC
resource "aws_vpc" "vpc" {
  cidr_block = "10.200.0.0/16"
  enable_dns_hostnames = true

    tags = {
    "Name" = "duongnb_vpc"
  }
}

# create internet gateway and attach it to vpc
resource "aws_internet_gateway" "ig" {
  vpc_id = aws_vpc.vpc.id

  tags = {
    "Name" = "duongnb_ig"
  }
}

# create public subnet az1
resource "aws_subnet" "public_subnet_az1" {
  vpc_id            = aws_vpc.vpc.id
  cidr_block        = "10.200.0.0/20"
  availability_zone = "ap-south-1a"
  map_public_ip_on_launch = true

  tags = {
    "Name" = "public-subnet_az1"
  }
}

# create public subnet az2
resource "aws_subnet" "public_subnet_az2" {
  vpc_id            = aws_vpc.vpc.id
  cidr_block        = "10.200.16.0/20"
  availability_zone = "ap-south-1b"
  map_public_ip_on_launch = true

  tags = {
    "Name" = "public-subnet_az2"
  }
}

# create public subnet az2
resource "aws_subnet" "public_subnet_az3" {
  vpc_id            = aws_vpc.vpc.id
  cidr_block        = "10.200.32.0/20"
  availability_zone = "ap-south-1c"
  map_public_ip_on_launch = true

  tags = {
    "Name" = "public-subnet_az3"
  }
}

# create route table and add public route
resource "aws_route_table" "public" {
  vpc_id = aws_vpc.vpc.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.ig.id
  }

  tags = {
    "Name" = "public"
  }
}
# associate public subnet az1 to "public route table"
resource "aws_route_table_association" "public_subnet_az1_route_table_association" {
  subnet_id           = aws_subnet.public_subnet_az1.id
  route_table_id      = aws_route_table.public.id
}

# associate public subnet az2 to "public route table"
resource "aws_route_table_association" "public_subnet_az2_route_table_association" {
  subnet_id           = aws_subnet.public_subnet_az2.id
  route_table_id      = aws_route_table.public.id
}

# associate public subnet az2 to "public route table"
resource "aws_route_table_association" "public_subnet_az3_route_table_association" {
  subnet_id           = aws_subnet.public_subnet_az3.id
  route_table_id      = aws_route_table.public.id
}

# create private subnet az1
resource "aws_subnet" "private_subnet_az1" {
  vpc_id            = aws_vpc.vpc.id
  cidr_block        = "10.200.48.0/20"
  availability_zone = "ap-south-1a"

  tags = {
    "Name" = "private-subnet_az1"
  }
}

# create private subnet az2
resource "aws_subnet" "private_subnet_az2" {
  vpc_id            = aws_vpc.vpc.id
  cidr_block        = "10.200.64.0/20"
  availability_zone = "ap-south-1b"

  tags = {
    "Name" = "private-subnet_az2"
  }
}

# create private subnet az3
resource "aws_subnet" "private_subnet_az3" {
  vpc_id            = aws_vpc.vpc.id
  cidr_block        = "10.200.80.0/20"
  availability_zone = "ap-south-1c"

  tags = {
    "Name" = "private-subnet_az3"
  }
}

# create data subnet az1
resource "aws_subnet" "data_subnet_az1" {
  vpc_id            = aws_vpc.vpc.id
  cidr_block        = "10.200.96.0/20"
  availability_zone = "ap-south-1a"

  tags = {
    "Name" = "data-subnet_az1"
  }
}

# create data subnet az2
resource "aws_subnet" "data_subnet_az2" {
  vpc_id            = aws_vpc.vpc.id
  cidr_block        = "10.200.112.0/20"
  availability_zone = "ap-south-1b"

  tags = {
    "Name" = "data-subnet_az2"
  }
}

# create data subnet az3
resource "aws_subnet" "data_subnet_az3" {
  vpc_id            = aws_vpc.vpc.id
  cidr_block        = "10.200.128.0/20"
  availability_zone = "ap-south-1c"

  tags = {
    "Name" = "data-subnet_az3"
  }
}

# allocate elastic ip. this eip will be used for the nat-gateway in the public subnet az1 
resource "aws_eip" "nat" {
  vpc = true
}

# create nat gateway in public subnet az1
resource "aws_nat_gateway" "public" {
  depends_on = [aws_internet_gateway.ig]

  allocation_id = aws_eip.nat.id
  subnet_id     = aws_subnet.public_subnet_az1.id

  tags = {
    Name = "Public NAT"
  }
}

# create router table in private 
resource "aws_route_table" "private" {
  vpc_id = aws_vpc.vpc.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_nat_gateway.public.id
  }

  tags = {
    "Name" = "private"
  }
}

# associate private subnet az1 to "private route table"
resource "aws_route_table_association" "private_subnet_az1_route_table_association" {
  subnet_id           = aws_subnet.private_subnet_az1.id
  route_table_id      = aws_route_table.private.id
}

#associate private subnet az2 to "private route table"
resource "aws_route_table_association" "private_subnet_az2_route_table_association" {
  subnet_id           = aws_subnet.private_subnet_az2.id
  route_table_id      = aws_route_table.private.id
}

#associate private subnet az2 to "private route table"
resource "aws_route_table_association" "private_subnet_az3_route_table_association" {
  subnet_id           = aws_subnet.private_subnet_az3.id
  route_table_id      = aws_route_table.private.id
}

# associate private subnet az1 to "private route table"
resource "aws_route_table_association" "data_subnet_az1_route_table_association" {
  subnet_id           = aws_subnet.data_subnet_az1.id
  route_table_id      = aws_route_table.private.id
}

# associate private subnet az2 to "private route table"
resource "aws_route_table_association" "data_subnet_az2_route_table_association" {
  subnet_id           = aws_subnet.data_subnet_az2.id
  route_table_id      = aws_route_table.private.id
}

# associate private subnet az2 to "private route table"
resource "aws_route_table_association" "data_subnet_az3_route_table_association" {
  subnet_id           = aws_subnet.data_subnet_az3.id
  route_table_id      = aws_route_table.private.id
}