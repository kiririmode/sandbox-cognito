output "hosted_ui_domain" {
  description = "Cognito の Hosted UI のドメイン"
  value       = aws_cognito_user_pool_domain.this.domain
}
