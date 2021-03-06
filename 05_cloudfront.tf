resource "aws_cloudfront_distribution" "s3_cloudfront" {
  origin {
    domain_name = aws_s3_bucket.website_s3.website_endpoint
    origin_id   = "S3-www.${var.fqdn}"

    custom_origin_config {
      http_port              = 80
      https_port             = 443
      origin_protocol_policy = "http-only"
      origin_ssl_protocols   = ["TLSv1", "TLSv1.1", "TLSv1.2"]
    }
  }

  aliases = [var.fqdn]

  enabled             = true
  default_root_object = "index.html"

  custom_error_response {
    error_caching_min_ttl = 0
    error_code            = 404
    response_code         = 200
    response_page_path    = "/index.html"
  }

  default_cache_behavior {
    allowed_methods  = ["GET", "HEAD"]
    cached_methods   = ["GET", "HEAD"]
    target_origin_id = "S3-www.${var.fqdn}"

    forwarded_values {
      query_string = false

      cookies {
        forward = "none"
      }
    }

    viewer_protocol_policy = "redirect-to-https"
    min_ttl                = 31536000
    default_ttl            = 31536000
    max_ttl                = 31536000
    compress               = true

    lambda_function_association {
      event_type   = "viewer-request"
      lambda_arn   = aws_lambda_function.fixed_http_basic_auth.qualified_arn
      include_body = false
    }
  }

  restrictions {
    geo_restriction {
      restriction_type = "none"
    }
  }

  viewer_certificate {
    acm_certificate_arn      = aws_acm_certificate.cloudfront_cert.arn
    ssl_support_method       = "sni-only"
    minimum_protocol_version = "TLSv1.1_2016"
  }
}


output "cloudfront_hosted_zone_id" {
  value = aws_cloudfront_distribution.s3_cloudfront.hosted_zone_id
}

output "cloudfront_fqdn" {
  value = aws_cloudfront_distribution.s3_cloudfront.domain_name
}
