# Output = Was soll terraform mir nach Apply anzeigen?
output "bucket" {
  value = aws_s3_bucket.uploads.bucket
}

output "db_secret" {
  value = aws_secretsmanager_secret.db.name
}