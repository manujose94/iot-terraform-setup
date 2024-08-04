resource "aws_s3_bucket" "base_bucket" {
  bucket = "${var.s3_bucket_prefix}-${var.environment}-bucket"
}
