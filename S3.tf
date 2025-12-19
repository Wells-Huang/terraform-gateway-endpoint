# --- Secure S3 Bucket ---
resource "aws_s3_bucket" "secure_bucket" {
  bucket_prefix = "demo-secure-bucket-"
  force_destroy = true

  tags = {
    Name = "demo-secure-bucket"
  }
}