# hier wird ein S3 Bucket erstellt, der von LocalStack emuliert wird
resource "aws_s3_bucket" "uploads" {
  bucket = local.bucket_name
}