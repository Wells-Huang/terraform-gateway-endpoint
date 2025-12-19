# 1. 取得目前執行 Terraform 的使用者身分 (e.g., your admin user)
data "aws_caller_identity" "current" {}

resource "random_id" "bucket_suffix" {
  byte_length = 4
}

resource "aws_s3_bucket" "secure_bucket" {
  bucket = "demo-secure-bucket-${random_id.bucket_suffix.hex}"
  
  force_destroy = true 

  tags = {
    Name = "DemoSecureBucket"
  }
}

resource "aws_s3_bucket_policy" "allow_vpc_only" {
  bucket = aws_s3_bucket.secure_bucket.id

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Sid       = "DenyAccessFromOutsideVPC"
        Effect    = "Deny"
        Principal = "*"
        Action    = "s3:*"
        Resource  = [
          aws_s3_bucket.secure_bucket.arn,
          "${aws_s3_bucket.secure_bucket.arn}/*"
        ]
        Condition = {
          # 這裡使用 AND 邏輯：
          # 當 (來源不是 VPC) 且 (來源不是 Terraform 管理員) 時，才執行 Deny
          StringNotEquals = {
            "aws:SourceVpc" = aws_vpc.main.id
          }
          ArnNotEquals = {
            "aws:PrincipalArn" = data.aws_caller_identity.current.arn
          }
        }
      },
      {
        Sid       = "AllowAccessFromVPC"
        Effect    = "Allow"
        Principal = "*"
        Action    = "s3:*"
        Resource  = [
          aws_s3_bucket.secure_bucket.arn,
          "${aws_s3_bucket.secure_bucket.arn}/*"
        ]
        Condition = {
          StringEquals = {
            "aws:SourceVpc" = aws_vpc.main.id
          }
        }
      }
    ]
  })
}
