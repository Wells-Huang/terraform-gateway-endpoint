# --- VPC ---
resource "aws_vpc" "main" {
  cidr_block           = "10.0.0.0/16"
  enable_dns_support   = true
  enable_dns_hostnames = true

  tags = {
    Name = "demo-vpc-tokyo"
  }
}

# --- Subnet ---
resource "aws_subnet" "private_subnet" {
  vpc_id            = aws_vpc.main.id
  cidr_block        = "10.0.1.0/24"
  availability_zone = "ap-northeast-1a"

  tags = {
    Name = "demo-subnet-ec2"
  }
}

# --- Route Table ---
resource "aws_route_table" "private_rt" {
  vpc_id = aws_vpc.main.id

  tags = {
    Name = "demo-private-rt"
  }
}

resource "aws_route_table_association" "private_assoc" {
  subnet_id      = aws_subnet.private_subnet.id
  route_table_id = aws_route_table.private_rt.id
}

# --- VPC Gateway Endpoint for S3 ---
# 這裡會自動在 Route Table 中加入指向 S3 (pl-xxxxx) 的路由
resource "aws_vpc_endpoint" "s3" {
  vpc_id       = aws_vpc.main.id
  service_name = "com.amazonaws.ap-northeast-1.s3"
  vpc_endpoint_type = "Gateway"
  
  # 關聯 Route Table，這實現了「請求直接走 AWS 內部網路」
  route_table_ids = [aws_route_table.private_rt.id]

  # Endpoint Policy: 決定這個 VPC 內的請求 可以經由此 Endpoint 存取特定 S3 資源
  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      # 1. 維持原需求：允許存取我們自己的 Secure Bucket
      {
        Sid       = "AllowAccessToSpecificBucketOnly"
        Effect    = "Allow"
        Principal = "*"
        Action    = "s3:*"
        Resource  = [
          aws_s3_bucket.secure_bucket.arn,
          "${aws_s3_bucket.secure_bucket.arn}/*"
        ]
      },
      # 2. 新增：允許 SSM Agent 存取該區域的 AWS 官方 SSM Bucket
      # 這是讓 EC2 在 Private Subnet 能正常運作的必要條件
      {
        Sid       = "AllowAccessToAWSSSMBuckets"
        Effect    = "Allow"
        Principal = "*"
        Action    = "s3:GetObject"
        Resource  = [
          "arn:aws:s3:::amazon-ssm-ap-northeast-1/*",
          "arn:aws:s3:::amazon-ssm-packages-ap-northeast-1/*"
        ]
      },
      # 3. (選用) 如果是 Amazon Linux 2，通常也需要存取 Yum Repository
      {
        Sid       = "AllowAccessToAmazonLinuxRepo"
        Effect    = "Allow"
        Principal = "*"
        Action    = "s3:GetObject"
        Resource  = [
          "arn:aws:s3:::amazonlinux.ap-northeast-1.amazonaws.com/*",
          "arn:aws:s3:::amazonlinux-2-repos-ap-northeast-1/*"
        ]
      }
    ]
  })

  tags = {
    Name = "demo-s3-gateway-endpoint"
  }
}
