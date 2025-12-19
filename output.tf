output "s3_bucket_name" {
  value = aws_s3_bucket.secure_bucket.id
}

output "instance_id" {
  value = aws_instance.app_server.id
}

output "vpc_endpoint_id" {
  value = aws_vpc_endpoint.s3.id
}
