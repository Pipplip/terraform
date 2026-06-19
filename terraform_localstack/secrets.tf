# Secrets Manager
# speichert sensitive Daten z.B. DB Passwort

# Unterschied zu SSM:
# - Rotation
# - Verschlüsselung mit KMS
# - Audit Log, also wer wann auf die Secrets zugegriffen hat

# Hülle mit Metadaten, z.B. Name, Beschreibung, Tags
resource "aws_secretsmanager_secret" "db" {
  name = "${local.env}/app/database"
}

# Eigentliche Werte, also z.B. Benutzername und Passwort
resource "aws_secretsmanager_secret_version" "db" {
  secret_id = aws_secretsmanager_secret.db.id

  secret_string = jsonencode({
    username = "app"
    password = "secret"
  })
}