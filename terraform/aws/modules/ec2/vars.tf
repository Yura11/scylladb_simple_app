variable "ami_id" {
  type        = string
  description = "AMI ID to use for the instance"
}

variable "instance_type" {
  type        = string
  description = "Instance type"
}

variable "subnet_id" {
  type        = string
  description = "Subnet ID to deploy the instance"
}

variable "vpc_id" {
  type        = string
  description = "VPC ID for the security group"
}

variable "project_name" {
  type        = string
  description = "Name of the project"
}

variable "tags" {
  type        = map(string)
  description = "Tags to apply to resources"
  default     = {}
}