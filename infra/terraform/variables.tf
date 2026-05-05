variable "aws_region" {
  description = "AWS region where resources will be created"
  type        = string
  default     = "us-east-1"

  validation {
    condition     = var.aws_region == "us-east-1"
    error_message = "Solo se permite la region us-east-1 en este entorno."
  }
}

variable "project_name" {
  description = "Project name prefix"
  type        = string
  default     = "cloud-deploy-platform"
}

variable "instance_type" {
  description = "EC2 instance type"
  type        = string
  default     = "t3.micro"
}
