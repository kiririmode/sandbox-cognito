locals {
  users = flatten(values(var.users))
}

resource "aws_cognito_user" "this" {
  for_each = toset(keys(var.users))

  user_pool_id             = aws_cognito_user_pool.this.id
  username                 = each.key
  attributes               = var.users[each.key]
  desired_delivery_mediums = ["EMAIL"]
}

### User Group については本来 IAM Role が紐づくため、
### 個々のグループごとにハードコードする
resource "aws_cognito_user_group" "group1" {
  user_pool_id = aws_cognito_user_pool.this.id
  name         = "group1"
}

resource "aws_cognito_user_group" "group2" {
  user_pool_id = aws_cognito_user_pool.this.id
  name         = "group2"
}

resource "aws_cognito_user_in_group" "group1" {
  for_each = toset(var.group_user_mapping["group1"])

  user_pool_id = aws_cognito_user_pool.this.id
  group_name   = "group1"
  username     = each.key

  depends_on = [
    aws_cognito_user_group.group1,
    aws_cognito_user_group.group2,
    aws_cognito_user.this,
  ]
}

resource "aws_cognito_user_in_group" "group2" {
  for_each = toset(var.group_user_mapping["group2"])

  user_pool_id = aws_cognito_user_pool.this.id
  group_name   = "group2"
  username     = each.key
}
