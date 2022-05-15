variable "custom_domain" {
  type        = string
  description = "独自ドメイン名。最後のピリオドは不要 (ex., example.com)"
}

variable "hostedui_domain_prefix" {
  type        = string
  description = "Cognito の Hosted UI に付与するドメインのプレフィックス"
}

variable "create_dummy_record" {
  type        = bool
  description = <<EOT
`custom_domain` の配下にダミーの A レコードを作る場合に true を指定する。

Cognito の Hosted UI にカスタムドメインを割り当てようとする場合、Cognito は
ルートドメインに対する A レコードを要求するため。

ref: 

- https://stackoverflow.com/questions/51249583/cognito-own-domain-name-required-a-record
- https://qiita.com/afukuma/items/4074fda7fa158eb387a3
EOT
  default     = false
}

variable "users" {
  type = map(object({
    email = string
  }))
  description = <<EOT
Cognito User Poolに設定するグループとユーザの組。

```
{
  "tarou@example.com" = {
    email: "tarou@example.com",
    hoge: "fuga"
  },
}
```
EOT
  default     = {}
}

variable "group_user_mapping" {
  type        = map(list(string))
  description = "どのグループにどのユーザが紐づくのかのマッピング。keyがグループ名、valueがユーザ名のlist。"
}
