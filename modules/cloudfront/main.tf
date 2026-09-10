# Origin Access Control — lets CloudFront access the private S3 bucket securely
resource "aws_cloudfront_origin_access_control" "this" {
  name                              = "${var.environment}-website-oac"
  description                       = "OAC for ${var.environment} static website"
  origin_access_control_origin_type = "s3"
  signing_behavior                  = "always"
  signing_protocol                  = "sigv4"
}

# CloudFront distribution — serves the website globally via CDN
resource "aws_cloudfront_distribution" "this" {
  enabled             = true
  default_root_object = "index.html"
  comment             = "${var.environment} static website"
  price_class         = var.price_class

  origin {
    domain_name              = var.s3_bucket_regional_domain_name
    origin_id                = "S3-${var.s3_bucket_id}"
    origin_access_control_id = aws_cloudfront_origin_access_control.this.id
  }

  default_cache_behavior {
    target_origin_id       = "S3-${var.s3_bucket_id}"
    viewer_protocol_policy = "redirect-to-https"  # forces all traffic to HTTPS
    allowed_methods        = ["GET", "HEAD"]
    cached_methods         = ["GET", "HEAD"]
    compress               = true

    forwarded_values {
      query_string = false
      cookies {
        forward = "none"
      }
    }
  }

  restrictions {
    geo_restriction {
      restriction_type = "none"
    }
  }

  viewer_certificate {
    cloudfront_default_certificate = true  # uses CloudFront's built-in SSL cert
  }

  tags = {
    Environment = var.environment
  }
}
