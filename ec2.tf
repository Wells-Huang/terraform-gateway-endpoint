# --- IAM Role for EC2 ---
resource "aws_iam_role" "ec2_s3_role" {
  name = "demo_ec2_s3_role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Action = "sts:AssumeRole"
      Effect = "Allow"
      Principal = {
        Service = "ec2.amazonaws.com"
      }
    }]
  })
}

# 給予 EC2 基本的 S3 存取權限 (實際存取還會被 VPC Endpoint Policy 和 Bucket Policy 過濾)
resource "aws_iam_role_policy_attachment" "s3_full_access" {
  role       = aws_iam_role.ec2_s3_role.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonS3FullAccess"
}

# 讓我們可以透過 SSM 連線進去測試 (Session Manager)
resource "aws_iam_role_policy_attachment" "ssm_core" {
  role       = aws_iam_role.ec2_s3_role.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonSSMManagedInstanceCore"
}

resource "aws_iam_instance_profile" "ec2_profile" {
  name = "demo_ec2_profile"
  role = aws_iam_role.ec2_s3_role.name
}

# --- Security Group ---
resource "aws_security_group" "ec2_sg" {
  name        = "demo-ec2-sg"
  description = "Allow outbound traffic to S3"
  vpc_id      = aws_vpc.main.id

  # 允許 HTTPS 外出流量 (S3 Endpoint 使用 443 port)
  egress {
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "demo-ec2-sg"
  }
}

# --- EC2 Instance ---
data "aws_ami" "amazon_linux_2" {
  most_recent = true
  owners      = ["amazon"]
  filter {
    name   = "name"
    values = ["amzn2-ami-hvm-*-x86_64-gp2"]
  }
}

resource "aws_instance" "app_server" {
  ami           = data.aws_ami.amazon_linux_2.id
  instance_type = "t3.micro"
  subnet_id     = aws_subnet.private_subnet.id
  iam_instance_profile = aws_iam_instance_profile.ec2_profile.name
  vpc_security_group_ids = [aws_security_group.ec2_sg.id]

  tags = {
    Name = "demo-app-server"
  }
}
