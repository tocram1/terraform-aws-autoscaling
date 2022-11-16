variable "aws_region" {
  type        = string
  description = "AWS Region"
}

variable "vpc_name" {
  type        = string
  description = "VPC Name"
}

variable "environment" {
  type    = string
  description = "The environment of the VPC."
}

variable "ami_id" {
  type       = string
  description = "ID of the AMI to use."
}

variable "availability_zones" {
  type        = map(string)
  description = "Availability zones for the subnets"
  default = {
    "a" = 0,
    "b" = 1,
  }
}