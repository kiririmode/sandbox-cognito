locals {
  hosted_ui_fqdn = "${var.hostedui_domain_prefix}.${var.custom_domain}"
}

data "aws_route53_zone" "this" {
  name = "${var.custom_domain}."
}

resource "aws_cognito_user_pool_domain" "this" {
  # 独自ドメインの場合は、FQDN を入力する
  domain = local.hosted_ui_fqdn

  certificate_arn = aws_acm_certificate.this.arn
  user_pool_id    = aws_cognito_user_pool.this.id

  depends_on = [
    aws_route53_record.dummy
  ]
}

# Hosted UI は CloudFront 経由でホストするため、us-east-1 でホストする必要がある

resource "aws_route53_record" "this" {
  provider = aws.acm_provider

  zone_id = data.aws_route53_zone.this.id
  name    = aws_cognito_user_pool_domain.this.domain
  type    = "A"

  alias {
    name                   = aws_cognito_user_pool_domain.this.cloudfront_distribution_arn
    evaluate_target_health = false

    # この Zone ID は固定値。
    # see: https://docs.aws.amazon.com/AWSCloudFormation/latest/UserGuide/quickref-route53.html#w2ab1c23c21c84c11
    zone_id = "Z2FDTNDATAQYW2"
  }
}

resource "aws_route53_record" "dummy" {
  count = var.create_dummy_record ? 1 : 0

  zone_id = data.aws_route53_zone.this.id
  name    = var.custom_domain
  type    = "A"
  ttl     = 60
  records = ["127.0.0.1"]
}

resource "aws_acm_certificate" "this" {
  provider = aws.acm_provider

  # 最後にピリオドをつけてはいけない
  domain_name       = local.hosted_ui_fqdn
  validation_method = "DNS"

  options {
    certificate_transparency_logging_preference = "ENABLED"
  }

  lifecycle {
    create_before_destroy = true
  }
}

# 証明書発行時の検証用に利用する DNS レコード
resource "aws_route53_record" "validation" {
  provider = aws.acm_provider

  for_each = {
    for dvo in aws_acm_certificate.this.domain_validation_options : dvo.domain_name => {
      name   = dvo.resource_record_name
      record = dvo.resource_record_value
      type   = dvo.resource_record_type
    }
  }

  zone_id         = data.aws_route53_zone.this.id
  name            = each.value.name
  type            = each.value.type
  ttl             = 60
  records         = [each.value.record]
  allow_overwrite = true
}

resource "aws_acm_certificate_validation" "this" {
  provider = aws.acm_provider

  certificate_arn         = aws_acm_certificate.this.arn
  validation_record_fqdns = [for record in aws_route53_record.validation : record.fqdn]
}
