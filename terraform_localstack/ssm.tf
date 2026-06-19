# SSM: eine Art Konfigurations-DB in AWS.
# Die go Anwendung liest diese Parameter zur Laufzeit aus.

resource "aws_ssm_parameter" "bucket" {
  name  = "/${local.env}/app/s3/bucket"
  type  = "String"
  value = aws_s3_bucket.uploads.bucket
}
# -> erzeugt den Parameter: /app/prod/db/host = db.example.com

resource "aws_ssm_parameter" "db_host" {
  name  = "/${local.env}/app/db/host"
  type  = "String"
  value = "postgres"
}