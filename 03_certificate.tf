resource "aws_acm_certificate" "cloudfront_cert" {
  provider          = aws.useast1  // CloudFront needs the certificate to be in us-east-1

  domain_name       = var.fqdn
  validation_method = "DNS"
}

output "certificate_domain_validation_options" {
  value = aws_acm_certificate.cloudfront_cert.domain_validation_options
}

output "certificate_domain_validation_arn" {
  value = aws_acm_certificate.cloudfront_cert.arn
}