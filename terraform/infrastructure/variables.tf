variable "aws_region" {
  type        = string
  default     = "us-east-1"
  description = "AWS Region quy định cho tài khoản Learner Lab"
}

variable "environment" {
  type        = string
  default     = "dev"
  description = "Môi trường triển khai ứng dụng"
}
