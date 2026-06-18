# output "infrastructure" {
#   description = "Gesamte Infrastruktur-Übersicht für den S3 Bucket"
#   value = {
#     bucket_name = aws_s3_bucket.test_bucket.bucket
#     bucket_id   = aws_s3_bucket.test_bucket.id
#     bucket_arn  = aws_s3_bucket.test_bucket.arn
#
#     # AWS/LocalStack technische Metadaten
#     bucket_domain_name          = aws_s3_bucket.test_bucket.bucket_domain_name
#     bucket_regional_domain_name = aws_s3_bucket.test_bucket.bucket_regional_domain_name
#     hosted_zone_id              = aws_s3_bucket.test_bucket.hosted_zone_id
#
#     # Praktische LocalStack-URLs
#     url_path_style = "http://localhost:4566/${aws_s3_bucket.test_bucket.bucket}"
#
#     url_virtual_hosted = "http://${aws_s3_bucket.test_bucket.bucket}.s3.localhost.localstack.cloud:4566"
#   }
# }
#
# output "bucket_name" {
#   description = "Nur der Bucket-Name"
#   value       = aws_s3_bucket.test_bucket.bucket
# }
#
# output "bucket_arn" {
#   description = "ARN des Buckets"
#   value       = aws_s3_bucket.test_bucket.arn
# }
#
# output "bucket_urls" {
#   description = "Verschiedene Zugriffs-URLs für LocalStack"
#   value = {
#     path_style     = "http://localhost:4566/${aws_s3_bucket.test_bucket.bucket}"
#     virtual_hosted = "http://${aws_s3_bucket.test_bucket.bucket}.s3.localhost.localstack.cloud:4566"
#   }
# }

output "bucket" {
  value = aws_s3_bucket.uploads.bucket
}

output "db_secret" {
  value = aws_secretsmanager_secret.db.name
}