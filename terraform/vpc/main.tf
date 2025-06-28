resource "aws_vpc" "vpc" {
  cidr_block       = var.VPC_CIDR
  instance_tenancy = "default"
  enable_dns_hostnames = true
  enable_dns_support   = true
  assign_generated_ipv6_cidr_block = false

  tags = {
    Name = "${var.PROJECT_NAME}-vpc"
  }
}
resource "aws_internet_gateway" "igw" {
  vpc_id = aws_vpc.vpc.id
  tags = {
    Name = "${var.PROJECT_NAME}-igw"
  }
}
data "aws_availability_zones" "availability_zones" {}

resource "aws_subnet" "pub_sub1" {
  vpc_id                    = aws_vpc.vpc.id
  cidr_block                = var.PUB_SUB1_CIDR
  map_public_ip_on_launch   = true
  availability_zone         = data.aws_availability_zones.availability_zones.names[0]
    tags = {
    Name                        = "pub-sub1"
    "kubernetes.io/cluster/${var.PROJECT_NAME}" = "shared"
    "kubernetes.io/role/elb" = 1
  }
}

resource "aws_subnet" "pub_sub2" {
  vpc_id                    = aws_vpc.vpc.id
  cidr_block                = var.PUB_SUB2_CIDR
  map_public_ip_on_launch   = true
  availability_zone         = data.aws_availability_zones.availability_zones.names[1]
  tags = {
    Name                        = "pub-sub2"
    "kubernetes.io/cluster/${var.PROJECT_NAME}" = "shared"
    "kubernetes.io/role/elb" = 1
  }
}

resource "aws_route_table" "pub_rt" {
  vpc_id = aws_vpc.vpc.id
  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.igw.id
  }
  tags = {
    Name = "${var.PROJECT_NAME}-pub_rt"
  }
}

resource "aws_route_table_association" "pub_rt_a" {
  subnet_id      = aws_subnet.pub_sub1.id
  route_table_id = aws_route_table.pub_rt.id
}

resource "aws_route_table_association" "pub_rt_b" {
  subnet_id      = aws_subnet.pub_sub2.id
  route_table_id = aws_route_table.pub_rt.id
}

resource "aws_subnet" "pri_sub3" {
  vpc_id             = aws_vpc.vpc.id
  cidr_block        = var.PRI_SUB3_CIDR
  availability_zone = data.aws_availability_zones.availability_zones.names[0]
  map_public_ip_on_launch = false
  
  tags = {
    Name                        = "pri-sub3"
    "kubernetes.io/cluster/${var.PROJECT_NAME}" = "shared"
    "kubernetes.io/role/internal-elb" = 1
  }
}
resource "aws_subnet" "pri_sub4" {
  vpc_id            = aws_vpc.vpc.id
  cidr_block        = var.PRI_SUB4_CIDR
  availability_zone = data.aws_availability_zones.availability_zones.names[1]
  map_public_ip_on_launch = false
  tags = {
    Name                        = "pri-sub4"
    "kubernetes.io/cluster/${var.PROJECT_NAME}" = "shared"
    "kubernetes.io/role/internal-elb" = 1
  }
}