#locals {
#  sb = flatten([
#    for k, v in var.vpcs : [
#      for subnet in v.subnets : {
#        vpc         = k
#        subnet_name = subnet.subnet_name
#        subnet_cidr = subnet.subnet_cidr
#        subnet_az   = subnet.subnet_az
#      }
#    ]
#  ])
#}
locals {
  subnets = flatten([
    for k, v in var.subnets : [
      for sbs in v : {
        subnet_name = sbs.subnet_name
        subnet_cidr = sbs.subnet_cidr
        subnet_zone = sbs.subnet_zone
        subnet_tags = sbs.tags
  }]])
}

# Virtual Private Cloud
resource "aws_vpc" "vpc" {
  cidr_block           = var.vpcs["vpc_cidr"]
  enable_dns_hostnames = true
  enable_dns_support   = true
  tags = {
    name = var.vpcs["vpc_name"]
  }
}

# Internet Gateway
resource "aws_internet_gateway" "igw" {
  vpc_id = aws_vpc.vpc.id
}

# Route table to IGW
resource "aws_route_table" "rtb_public" {
  vpc_id = aws_vpc.vpc.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.igw.id
  }
}

resource "aws_route_table_association" "rtb_public_assoc" {
  for_each = {
    for s in local.subnets : "${s.subnet_name}" => s if "${s.subnet_name}" == "public1a" || "${s.subnet_name}" == "public1b"
  }
  subnet_id      = aws_subnet.subnet[each.value.subnet_name].id
  route_table_id = aws_route_table.rtb_public.id
}

# Subnet
resource "aws_subnet" "subnet" {
  for_each = { for s in local.subnets : "${s.subnet_name}" => s }
  #for s in local.sb : "${s.vpc_name}.${s.subnet_name}" => s
  #for s in local.sb : "${s.subnet_name}" => s
  availability_zone       = each.value.subnet_zone
  vpc_id                  = aws_vpc.vpc.id
  cidr_block              = each.value.subnet_cidr
  tags                    = each.value.subnet_tags
}