locals {
  public_subnet_map  = { for index, cidr in var.public_subnets : tostring(index) => cidr }
  private_subnet_map = { for index, cidr in var.private_subnets : tostring(index) => cidr }
}

resource "aws_vpc" "this" {
  cidr_block           = var.vpc_cidr_block
  enable_dns_support   = true
  enable_dns_hostnames = true

  tags = merge(var.tags, {
    Name        = var.vpc_name
    Environment = "lesson-5"
    ManagedBy   = "Terraform"
  })
}

resource "aws_subnet" "public" {
  for_each = local.public_subnet_map

  vpc_id                  = aws_vpc.this.id
  cidr_block              = each.value
  availability_zone       = var.availability_zones[tonumber(each.key)]
  map_public_ip_on_launch = true

  tags = merge(var.tags, {
    Name        = "${var.vpc_name}-public-${tonumber(each.key) + 1}"
    Tier        = "public"
    Environment = "lesson-5"
    ManagedBy   = "Terraform"
  })
}

resource "aws_subnet" "private" {
  for_each = local.private_subnet_map

  vpc_id            = aws_vpc.this.id
  cidr_block        = each.value
  availability_zone = var.availability_zones[tonumber(each.key)]

  tags = merge(var.tags, {
    Name        = "${var.vpc_name}-private-${tonumber(each.key) + 1}"
    Tier        = "private"
    Environment = "lesson-5"
    ManagedBy   = "Terraform"
  })
}

resource "aws_internet_gateway" "this" {
  vpc_id = aws_vpc.this.id

  tags = merge(var.tags, {
    Name        = "${var.vpc_name}-igw"
    Environment = "lesson-5"
    ManagedBy   = "Terraform"
  })
}

resource "aws_eip" "nat" {
  domain = "vpc"

  tags = merge(var.tags, {
    Name        = "${var.vpc_name}-nat-eip"
    Environment = "lesson-5"
    ManagedBy   = "Terraform"
  })
}

resource "aws_nat_gateway" "this" {
  allocation_id = aws_eip.nat.id
  subnet_id     = aws_subnet.public["0"].id

  depends_on = [aws_internet_gateway.this]

  tags = merge(var.tags, {
    Name        = "${var.vpc_name}-nat"
    Environment = "lesson-5"
    ManagedBy   = "Terraform"
  })
}
