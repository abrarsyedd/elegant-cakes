output "ec2_public_ip" {
  description = "EC2 Instance Public IP"
  value = aws_instance.web.public_ip
}

output "alb_dns" {
  description = "ALB DNS Name"
  value = aws_lb.alb.dns_name
}

output "rds_endpoint_endpoint" {
  description = "RDS Endpoint"
  value = aws_db_instance.cakeshop_rds.address
}

output "bucket_endpoint" {
  description = "The regional domain name for the S3 bucket"
  value       = aws_s3_bucket.assets_bucket.bucket_regional_domain_name
}
