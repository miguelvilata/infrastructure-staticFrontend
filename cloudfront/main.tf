#############
## Cloudfront
#############

resource "aws_cloudfront_origin_access_identity" "origin_access_identity" {
  comment = var.project
}
locals {
  s3_origin_id = data.terraform_remote_state.bucket.outputs.bucket_id
}
resource "aws_cloudfront_distribution" "s3_distribution" {
  origin {
    domain_name = "${data.terraform_remote_state.bucket.outputs.bucket_id}.s3.amazonaws.com"
    origin_id   = "Custom-${local.s3_origin_id}"

    s3_origin_config {
      origin_access_identity = "origin-access-identity/cloudfront/${aws_cloudfront_origin_access_identity.origin_access_identity.id}"
    }
  }

  enabled             = true
  is_ipv6_enabled     = true
  default_root_object = var.root_object

  aliases = [var.aliases]

  default_cache_behavior {
    allowed_methods  = ["DELETE", "GET", "HEAD", "OPTIONS", "PATCH", "POST", "PUT"]
    cached_methods   = ["GET", "HEAD"]
    target_origin_id = "Custom-${local.s3_origin_id}"

    forwarded_values {
      query_string = false
      #headers = ["none"]
      cookies {
        forward = "none"
      }
    }
    min_ttl                = 0
    default_ttl            = 3600
    max_ttl                = 86400
    compress               = true
    viewer_protocol_policy = "redirect-to-https"
  }

  price_class = "PriceClass_All"

  restrictions {
    geo_restriction {
      restriction_type = "none"
      #restriction_type = "whitelist"
      #locations        = ["US"] #["US", "CA", "GB", "DE"]
    }
  }
  tags = {
    Create_by   = var.creator
    Environment = var.environment
    Project     = var.project
    Technology  = var.technology
    Terraform   = var.terraform
  }
  viewer_certificate {
    acm_certificate_arn      = data.terraform_remote_state.acm.outputs.certificate_cloudfront_arn
    minimum_protocol_version = var.minimum_protocol_version
    ssl_support_method       = var.ssl_support_method
  }
}
resource "aws_route53_record" "alias_record" {
  name    = var.aliases
  type    = "A"
  zone_id = var.dns_zone_id
  alias {
    name                   = aws_cloudfront_distribution.s3_distribution.domain_name
    zone_id                = aws_cloudfront_distribution.s3_distribution.hosted_zone_id
    evaluate_target_health = true
  }
}

resource "aws_s3_bucket_policy" "bucket" {
  bucket = data.terraform_remote_state.bucket.outputs.bucket_id

  policy = <<POLICY
{
    "Version": "2008-10-17",
    "Id": "PolicyForCloudFrontPrivateContent",
    "Statement": [
        {
            "Sid": "1",
            "Effect": "Allow",
            "Principal": {
                "AWS": "${aws_cloudfront_origin_access_identity.origin_access_identity.iam_arn}"
            },
            "Action": "s3:GetObject",
            "Resource": "arn:aws:s3:::${data.terraform_remote_state.bucket.outputs.bucket_id}/*"
        }
    ]
}
POLICY
}