resource "aws_s3_bucket" "uploads" {
  bucket = "uploads-bucket-${replace(terraform.workspace, "_", "-")}"
}