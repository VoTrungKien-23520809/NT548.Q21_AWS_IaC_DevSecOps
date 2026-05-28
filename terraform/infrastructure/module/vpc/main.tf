# 1. Khởi tạo VPC
resource "aws_vpc" "main" {
  cidr_block           = var.vpc_cidr
  enable_dns_hostnames = true
  enable_dns_support   = true

  tags = {
    Name        = "${var.environment}-vpc"
    Environment = var.environment
  }
}

# 2. Khởi tạo Internet Gateway để Public Subnet ra được Internet
resource "aws_internet_gateway" "gw" {
  vpc_id = aws_vpc.main.id

  tags = {
    Name        = "${var.environment}-igw"
    Environment = var.environment
  }
}

# 3. Khởi tạo Public Subnet
resource "aws_subnet" "public" {
  vpc_id                  = aws_vpc.main.id
  cidr_block              = var.public_subnet_cidr
  map_public_ip_on_launch = true 			# Đảm bảo EC2 trong này tự động nhận Public IP
  availability_zone       = "us-east-1a"

  tags = {
    Name        = "${var.environment}-public-subnet"
    Environment = var.environment
  }
}

# 4. Khởi tạo Private Subnet
resource "aws_subnet" "private" {
  vpc_id            = aws_vpc.main.id
  cidr_block        = var.private_subnet_cidr
  availability_zone = "us-east-1a"

  tags = {
    Name        = "${var.environment}-private-subnet"
    Environment = var.environment
  }
}
