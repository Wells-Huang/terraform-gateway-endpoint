# --- Security Group for SSM Endpoints ---
# 允許 VPC 內部的機器透過 HTTPS (443) 連線到這些 Endpoints
resource "aws_security_group" "ssm_sg" {
  name        = "demo-ssm-endpoint-sg"
  description = "Allow TLS for SSM"
  vpc_id      = aws_vpc.main.id

  ingress {
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    cidr_blocks = [aws_vpc.main.cidr_block]
  }

  tags = {
    Name = "demo-ssm-endpoint-sg"
  }
}

# --- SSM Interface Endpoints ---
# 1. SSM Core
resource "aws_vpc_endpoint" "ssm" {
  vpc_id            = aws_vpc.main.id
  service_name      = "com.amazonaws.ap-northeast-1.ssm"
  vpc_endpoint_type = "Interface"
  subnet_ids        = [aws_subnet.private_subnet.id]
  security_group_ids = [aws_security_group.ssm_sg.id]
  private_dns_enabled = true
}

# 2. EC2 Messages
resource "aws_vpc_endpoint" "ec2messages" {
  vpc_id            = aws_vpc.main.id
  service_name      = "com.amazonaws.ap-northeast-1.ec2messages"
  vpc_endpoint_type = "Interface"
  subnet_ids        = [aws_subnet.private_subnet.id]
  security_group_ids = [aws_security_group.ssm_sg.id]
  private_dns_enabled = true
}

# 3. SSM Messages (for Session Manager)
resource "aws_vpc_endpoint" "ssmmessages" {
  vpc_id            = aws_vpc.main.id
  service_name      = "com.amazonaws.ap-northeast-1.ssmmessages"
  vpc_endpoint_type = "Interface"
  subnet_ids        = [aws_subnet.private_subnet.id]
  security_group_ids = [aws_security_group.ssm_sg.id]
  private_dns_enabled = true
}
