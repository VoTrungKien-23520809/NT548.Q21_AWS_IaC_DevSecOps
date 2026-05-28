variable "vpc_id" {
  type        = string
  description = "ID của VPC nhận từ module vpc"
}

variable "public_subnet_id" {
  type        = string
  description = "ID của Public Subnet"
}

variable "private_subnet_id" {
  type        = string
  description = "ID của Private Subnet"
}

variable "environment" {
  type        = string
  default     = "dev"
}

variable "instance_type" {
  type        = string
  default     = "t3.micro" 
}

variable "my_ip" {
  type        = string
  default     = "0.0.0.0/0" 
  description = "IP của người dùng dùng để giới hạn SSH vào Public EC2"
}
