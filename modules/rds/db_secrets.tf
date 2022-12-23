resource "random_password" "db_password" {
  length           = 16
  special          = true
  override_special = "_"
  min_lower = 1
  min_upper = 1
  min_numeric = 1
  min_special = 2
}

resource "aws_secretsmanager_secret" "db_secret" {
  name  = "db_password"
  recovery_window_in_days = 0
}

resource "aws_secretsmanager_secret_version" "db_pass" {
  secret_id     = aws_secretsmanager_secret.db_secret.id
  secret_string = random_password.db_password.result
}
