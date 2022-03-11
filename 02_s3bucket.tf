resource "aws_s3_bucket" "website_s3" {
  bucket = var.fqdn
}

resource "aws_cloudfront_origin_access_identity" "s3_cloudfront_oai" {
  comment = "CloudFront Access Identity for S3 hosted website ${var.fqdn}"
}

resource "aws_s3_bucket_policy" "policy_s3" {
  bucket = aws_s3_bucket.website_s3.id
  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Sid = "S3WebBucket"
        Principal = {
          AWS = aws_cloudfront_origin_access_identity.s3_cloudfront_oai.iam_arn
        }
        Action   = "s3:GetObject"
        Effect   = "Allow"
        Resource = ["${aws_s3_bucket.website_s3.arn}/*"]
      }
    ]
  })
}

resource "aws_s3_bucket_acl" "acl_s3" {
  bucket = aws_s3_bucket.website_s3.id
  acl = "public-read"
}

resource "aws_s3_bucket_website_configuration" "website_config" {
  bucket = aws_s3_bucket.website_s3.id

  index_document {
    suffix = "index.html"
  }

  error_document {
    key = "error.html"
  }
}

resource "aws_s3_bucket_cors_configuration" "example" {
  bucket = aws_s3_bucket.website_s3.id

  cors_rule {
    allowed_headers = ["Authorization"]
    allowed_methods = ["GET", "HEAD"]
    allowed_origins = ["https://${var.fqdn}"]
    max_age_seconds = 3000
  }
}