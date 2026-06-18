resource "aws_ssm_parameter" "bucket" {
  name  = "/app/s3/bucket"
  type  = "String"
  value = aws_s3_bucket.uploads.bucket
}

resource "aws_ssm_parameter" "db_host" {
  name  = "/app/db/host"
  type  = "String"
  value = "postgres"
}