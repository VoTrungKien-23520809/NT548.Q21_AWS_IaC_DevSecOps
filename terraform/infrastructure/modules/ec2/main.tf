# ==========================================================
# CẤU HÌNH SECURITY GROUPS (SG)
# ==========================================================

# 1. Security Group cho Public EC2 Instance (Bastion Host)
resource "aws_security_group" "public_sg" {
  name        = "${var.environment}-public-ec2-sg"
  description = "Chi cho phep SSH tu IP cu the"
  vpc_id      = var.vpc_id

  # Inbound rule: 
  ingress {
    description = "SSH tu IP nguoi dung"
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = [var.my_ip] # Tuân thủ yêu cầu 
  }

  # Outbound rule: Cho phép đi ra ngoài Internet 
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name        = "${var.environment}-public-sg"
    Environment = var.environment
  }
}

# 2. Security Group cho Private EC2 Instance
resource "aws_security_group" "private_sg" {
  name        = "${var.environment}-private-ec2-sg"
  description = "Chi cho phep ket noi tu Public EC2 Instance"
  vpc_id      = var.vpc_id

  # Inbound rule: Chỉ nhận traffic từ Security Group của Public EC2
  ingress {
    description     = "SSH chi tu Public EC2 SG"
    from_port       = 22
    to_port         = 22
    protocol        = "tcp"
    security_groups = [aws_security_group.public_sg.id] # Tuân thủ yêu cầu 
  }

  # Outbound rule: Cho phép đi ra ngoài (sẽ đi qua NAT GW nhờ Route Table cũ)
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name        = "${var.environment}-private-sg"
    Environment = var.environment
  }
}

# ==========================================================
# KHỞI TẠO KEY PAIR TỰ ĐỘNG
# ==========================================================

# 1. Tạo thuật toán mã hóa RSA cho Key
resource "tls_private_key" "pk" {
  algorithm = "RSA"
  rsa_bits  = 4096
}

# 2. Đăng ký Public Key lên AWS Key Pair
resource "aws_key_pair" "generated_key" {
  key_name   = "${var.environment}-deployer-key"
  public_key = tls_private_key.pk.public_key_openssh

  tags = {
    Name        = "${var.environment}-key"
    Environment = var.environment
  }
}

# 3. Xuất file Private Key (.pem) về máy local để lát nữa bạn dùng SSH
resource "local_file" "ssh_key" {
  filename        = "${path.root}/${var.environment}-deployer-key.pem"
  content         = tls_private_key.pk.private_key_pem
  file_permission = "0400" # Phân quyền chỉ đọc để bảo mật Key theo chuẩn SSH
}

# ==========================================================
# KHỞI TẠO EC2 INSTANCES
# ==========================================================

# Lấy AMI Ubuntu 22.04 LTS 
data "aws_ami" "ubuntu" {
  most_recent = true
  owners      = ["099720109477"] # ID tài khoản chính thức của Canonical trên AWS

  filter {
    name   = "name"
    values = ["ubuntu/images/hvm-ssd/ubuntu-jammy-22.04-amd64-server-*"]
  }

  filter {
    name   = "virtualization-type"
    values = ["hvm"]
  }
}

# 3. Tạo Public EC2 Instance
resource "aws_instance" "public_ec2" {
  ami                         = data.aws_ami.ubuntu.id
  instance_type               = var.instance_type
  subnet_id                   = var.public_subnet_id
  vpc_security_group_ids      = [aws_security_group.public_sg.id]
  associate_public_ip_address = true
  key_name                    = aws_key_pair.generated_key.key_name

  tags = {
    Name        = "${var.environment}-public-instance"
    Environment = var.environment
  }
}

# 4. Tạo Private EC2 Instance
resource "aws_instance" "private_ec2" {
  ami                    = data.aws_ami.ubuntu.id
  instance_type          = var.instance_type
  subnet_id              = var.private_subnet_id
  vpc_security_group_ids = [aws_security_group.private_sg.id]
  key_name               = aws_key_pair.generated_key.key_name

  tags = {
    Name        = "${var.environment}-private-instance"
    Environment = var.environment
  }
}
