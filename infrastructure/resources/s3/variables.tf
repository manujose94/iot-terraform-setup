variable "s3_bucket_prefix" {
  description = "Prefix for S3 bucket names"
  type = string
  default = "test-cloudiot"
}

variable "environment" {
  description = "The environment where resources will be provisioned."
  type        = string
}
