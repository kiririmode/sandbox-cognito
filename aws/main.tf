resource "aws_cognito_user_pool" "this" {
  name = "project"

  # ユーザによるパスワードリセット時の方法に関する優先度づけ
  account_recovery_setting {
    recovery_mechanism {
      name     = "verified_phone_number" # SMS
      priority = 1
    }
    recovery_mechanism {
      name     = "verified_email"
      priority = 2
    }
  }

  mfa_configuration = "ON"
  software_token_mfa_configuration {
    enabled = true
  }
  sms_authentication_message = "セキュリティコード: {####}"
  # TODO: sms_configuration

  username_configuration {
    # ログインを e-mail で行うつもりであるため、大文字・小文字を区別しない
    case_sensitive = false
  }


  # 管理者だけがユーザを作成できるか否かの設定
  admin_create_user_config {
    # 契約企業のユーザを作れるのはオーナーのみ
    allow_admin_create_user_only = true
  }

  # 新しいデバイスでログインを行う場合はユーザにチャレンジ試行を行う
  # TODO: 実際に利用した上で、本当に使うかを判断する。
  device_configuration {
    challenge_required_on_new_device      = true
    device_only_remembered_on_user_prompt = false
  }

  # TODO: メール設定。SES に乗り換える必要がある。
  email_configuration {
    email_sending_account = "COGNITO_DEFAULT"
  }

  password_policy {
    # NIST は多要素認証、ユーザーが作成するパスワードは最小 8 文字としている
    # ref: https://jpn.nec.com/cybersecurity/blog/200918/index.html
    minimum_length = 8

    require_lowercase                = true
    require_numbers                  = true
    require_symbols                  = true
    require_uppercase                = true
    temporary_password_validity_days = 7
  }

  # TODO: schema は別途検討
  # Cognito 側にあまり多くの情報を持つのは非推奨だったはずなので、最小限に留める
  schema {
    attribute_data_type = "String"
    name                = "email"
    required            = true
    string_attribute_constraints {
      min_length = 1
      max_length = 256
    }
  }
}

resource "aws_cognito_user_pool_client" "name" {
  name         = "client"
  user_pool_id = aws_cognito_user_pool.this.id

  # SPA なので、クライアントシークレットを発行したとしてもセキュアに守れない
  generate_secret       = false
  access_token_validity = 1

  callback_urls = [
    "http://localhost:8080/"
  ]

  allowed_oauth_flows = ["code"]
  explicit_auth_flows = [
    "ALLOW_USER_SRP_AUTH",
    "ALLOW_REFRESH_TOKEN_AUTH"
  ]
  supported_identity_providers = [
    "COGNITO"
  ]
  allowed_oauth_scopes                 = ["openid"]
  allowed_oauth_flows_user_pool_client = true

}
