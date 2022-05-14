data "aws_route53_zone" "kiririmode" {
  name = "kiririmo.de."
}

resource "aws_cognito_user_pool_domain" "this" {
  domain = "auth-example"
  # certificate_arn = aws_acm_certificate.cert.arn
  user_pool_id = aws_cognito_user_pool.this.id
}

resource "aws_route53_record" "this" {
  zone_id = data.aws_route53_zone.kiririmode.id
  name    = aws_cognito_user_pool_domain.this.domain
  type    = "A"

  alias {
    name                   = aws_cognito_user_pool_domain.this.cloudfront_distribution_arn
    evaluate_target_health = false
    # This zone_id is fixed
    zone_id = "Z2FDTNDATAQYW2"
  }
}

