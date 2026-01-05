variable "project_name" {
  description = "Project name to be used for resource naming"
  type        = string
  default     = "demo"
}

variable "environment" {
  description = "Environment (e.g., dev, prod)"
  type        = string
  default     = "dev"
}

variable "region" {
  description = "AWS Region"
  type        = string
  default     = "ap-northeast-1"
}
