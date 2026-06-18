resource "aws_secretsmanager_secret" "db" {
  name = "app/database"
}

resource "aws_secretsmanager_secret_version" "db" {
  secret_id = aws_secretsmanager_secret.db.id

  secret_string = jsonencode({
    username = "app"
    password = "secret"
  })
}