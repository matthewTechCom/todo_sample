output "frontend_bucket_name" {
  description = "S3 bucket name for frontend assets."
  value       = aws_s3_bucket.frontend.bucket
}

output "frontend_distribution_id" {
  description = "CloudFront distribution ID."
  value       = aws_cloudfront_distribution.app.id
}

output "frontend_url" {
  description = "Frontend public CloudFront URL."
  value       = "https://${aws_cloudfront_distribution.app.domain_name}"
}

output "backend_url" {
  description = "Backend public API base URL on the shared CloudFront distribution."
  value       = "https://${aws_cloudfront_distribution.app.domain_name}"
}

output "backend_ecr_repository_url" {
  description = "ECR repository URL for the Rails container image."
  value       = aws_ecr_repository.backend.repository_url
}

output "rds_endpoint" {
  description = "RDS endpoint address."
  value       = aws_db_instance.backend.address
}

output "backend_alb_dns_name" {
  description = "Backend ALB DNS name used as the CloudFront origin."
  value       = aws_lb.backend.dns_name
}
