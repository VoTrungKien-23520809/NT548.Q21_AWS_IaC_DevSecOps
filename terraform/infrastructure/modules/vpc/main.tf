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

# ==========================================================
# CẤU HÌNH NAT GATEWAY (Cho Private Subnet)
# ==========================================================

# 5. Tạo Elastic IP (EIP) cho NAT Gateway
resource "aws_eip" "nat" {
  domain = "vpc"

  tags = {
    Name        = "${var.environment}-nat-eip"
    Environment = var.environment
  }
}

# 6. Khởi tạo NAT Gateway (Bắt buộc phải đặt ở Public Subnet)
resource "aws_nat_gateway" "main" {
  allocation_id = aws_eip.nat.id
  subnet_id     = aws_subnet.public.id # Đặt ở Public để mượn đường ra ngoài

  tags = {
    Name        = "${var.environment}-nat-gw"
    Environment = var.environment
  }

  # Đảm bảo Internet Gateway phải được tạo trước rồi mới tạo NAT Gateway
  depends_on = [aws_internet_gateway.gw]
}


# ==========================================================
# CẤU HÌNH ROUTE TABLES & ASSOCIATIONS
# ==========================================================

# 7. Public Route Table: Định tuyến qua Internet Gateway (IGW)
resource "aws_route_table" "public" {
  vpc_id = aws_vpc.main.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.gw.id
  }

  tags = {
    Name        = "${var.environment}-public-rt"
    Environment = var.environment
  }
}

# 8. Gắn Public Route Table vào Public Subnet
resource "aws_route_table_association" "public" {
  subnet_id      = aws_subnet.public.id
  route_table_id = aws_route_table.public.id
}

# 9. Private Route Table: Định tuyến qua NAT Gateway
resource "aws_route_table" "private" {
  vpc_id = aws_vpc.main.id

  route {
    cidr_block     = "0.0.0.0/0"
    nat_gateway_id = aws_nat_gateway.main.id
  }

  tags = {
    Name        = "${var.environment}-private-rt"
    Environment = var.environment
  }
}

# 10. Gắn Private Route Table vào Private Subnet
resource "aws_route_table_association" "private" {
  subnet_id      = aws_subnet.private.id
  route_table_id = aws_route_table.private.id
}
