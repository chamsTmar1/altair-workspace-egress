terraform {
  required_version = ">= 1.0"

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
  }
}

provider "aws" {
  region = var.aws_region

  default_tags {
    tags = {
      Project     = "AltairWorkSpaceEgress"
      Environment = "Sandbox"
      ManagedBy   = "Terraform"
      Owner       = var.owner
    }
  }
}

# Data source to get current AWS account info
data "aws_caller_identity" "current" {}

locals {
  az_primary   = "${var.aws_region}a" # For NAT Gateway
  az_secondary = "${var.aws_region}c" # For second WorkSpaces subnet

  common_tags = {
    Description = "Single EIP egress for WorkSpaces to Altair"
  }
}

#-----------------------------------------------------------
# VPC
#-----------------------------------------------------------
resource "aws_vpc" "main" {
  cidr_block           = var.vpc_cidr
  enable_dns_support   = true
  enable_dns_hostnames = true

  tags = merge(local.common_tags, {
    Name = "${var.project_name}-vpc"
  })
}

#-----------------------------------------------------------
# Internet Gateway
#-----------------------------------------------------------
resource "aws_internet_gateway" "igw" {
  vpc_id = aws_vpc.main.id

  tags = {
    Name = "${var.project_name}-igw"
  }
}

#-----------------------------------------------------------
# Subnets
#-----------------------------------------------------------

# Public subnet for NAT Gateway
resource "aws_subnet" "public" {
  vpc_id                  = aws_vpc.main.id
  cidr_block              = var.public_subnet_cidr
  availability_zone       = local.az_primary
  map_public_ip_on_launch = true

  tags = {
    Name = "${var.project_name}-public-${local.az_primary}"
    Type = "Public"
  }
}

# Private subnet 1 for WorkSpaces
resource "aws_subnet" "private_ws_1" {
  vpc_id            = aws_vpc.main.id
  cidr_block        = var.private_subnet_1_cidr
  availability_zone = local.az_primary

  tags = {
    Name = "${var.project_name}-ws-private-1-${local.az_primary}"
    Type = "Private-WorkSpaces"
  }
}

# Private subnet 2 for WorkSpaces (WorkSpaces requires 2 subnets in different AZs!!)
resource "aws_subnet" "private_ws_2" {
  vpc_id            = aws_vpc.main.id
  cidr_block        = var.private_subnet_2_cidr
  availability_zone = local.az_secondary

  tags = {
    Name = "${var.project_name}-ws-private-2-${local.az_secondary}"
    Type = "Private-WorkSpaces"
  }
}

#-----------------------------------------------------------
# Elastic IP for NAT Gateway
#-----------------------------------------------------------
resource "aws_eip" "nat" {
  domain = "vpc"

  tags = {
    Name        = "${var.project_name}-nat-eip"
    Description = "Static IP for Altair whitelist"
  }

  depends_on = [aws_internet_gateway.igw]
}

#-----------------------------------------------------------
# NAT Gateway
#-----------------------------------------------------------
resource "aws_nat_gateway" "nat" {
  allocation_id = aws_eip.nat.id
  subnet_id     = aws_subnet.public.id

  tags = {
    Name = "${var.project_name}-natgw"
  }

  depends_on = [aws_internet_gateway.igw]
}

#-----------------------------------------------------------
# Route Tables
#-----------------------------------------------------------

# Public route table
resource "aws_route_table" "public" {
  vpc_id = aws_vpc.main.id

  tags = {
    Name = "${var.project_name}-rt-public"
  }
}

resource "aws_route" "public_internet" {
  route_table_id         = aws_route_table.public.id
  destination_cidr_block = "0.0.0.0/0"
  gateway_id             = aws_internet_gateway.igw.id
}

resource "aws_route_table_association" "public" {
  subnet_id      = aws_subnet.public.id
  route_table_id = aws_route_table.public.id
}

# Private route table for WorkSpaces
resource "aws_route_table" "private_ws" {
  vpc_id = aws_vpc.main.id

  tags = {
    Name = "${var.project_name}-rt-ws-private"
  }
}

resource "aws_route" "private_nat" {
  route_table_id         = aws_route_table.private_ws.id
  destination_cidr_block = "0.0.0.0/0"
  nat_gateway_id         = aws_nat_gateway.nat.id
}

resource "aws_route_table_association" "private_ws_1" {
  subnet_id      = aws_subnet.private_ws_1.id
  route_table_id = aws_route_table.private_ws.id
}

resource "aws_route_table_association" "private_ws_2" {
  subnet_id      = aws_subnet.private_ws_2.id
  route_table_id = aws_route_table.private_ws.id
}
