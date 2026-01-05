# --- Secure S3 Bucket ---
resource "aws_s3_bucket" "secure_bucket" {
  bucket_prefix = "${var.project_name}-secure-bucket-"
  force_destroy = true

  tags = {
    Name = "${var.project_name}-secure-bucket"
  }
}