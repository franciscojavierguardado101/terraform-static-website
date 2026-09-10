# Inputs this module expects from the environment that calls it

variable "bucket_name" {
  type        = string
  description = "Name of the S3 bucket for the website"
}

variable "environment" {
  type        = string
  description = "Environment name (dev, staging, prod)"
}
