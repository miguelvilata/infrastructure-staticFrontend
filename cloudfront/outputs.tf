output "cloudfront_name" {
  value       = aws_cloudfront_distribution.s3_distribution.domain_name
  description = "The domain name of the CloudFront distribution"
}
output "cloudfront_arn" {
  value       = aws_cloudfront_distribution.s3_distribution.arn
  description = "The domain name of the CloudFront distribution"
}
