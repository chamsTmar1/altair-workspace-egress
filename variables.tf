variable "aws_region" {
  description = "AWS region for deployment"
  type        = string
  default     = "us-east-1"
}

variable "project_name" {
  description = "Project name for resource naming"
  type        = string
  default     = "altair-ws-egress"
}

variable "owner" {
  description = "Owner tag for resources"
  type        = string
  default     = "chamstamer"
}

variable "vpc_cidr" {
  description = "CIDR block for VPC"
  type        = string
  default     = "10.20.0.0/16"
}

variable "public_subnet_cidr" {
  description = "CIDR block for public subnet (NAT Gateway)"
  type        = string
  default     = "10.20.0.0/24"
}

variable "private_subnet_1_cidr" {
  description = "CIDR block for first private subnet (WorkSpaces)"
  type        = string
  default     = "10.20.10.0/24"
}

variable "private_subnet_2_cidr" {
  description = "CIDR block for second private subnet (WorkSpaces)"
  type        = string
  default     = "10.20.11.0/24"
}