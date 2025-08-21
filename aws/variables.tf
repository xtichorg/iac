variable "aws_region" {
  default     = "us-east-1"
  type        = string
  description = "AWS region"
}

variable "prefix" {
  default     = "x"
  type        = string
  description = "Prefix for resource names"
}

variable "azs_count" {
  default     = 3
  type        = number
  description = "Number of availability zones to use for the VPC"
}