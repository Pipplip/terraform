# Konfiguriere den Provider. 'aws' wurde so als name in terraform.tf definiert.
provider "aws" {
  access_key                  = "test"
  secret_key                  = "test"
  region                      = "eu-west-1"
  s3_use_path_style           = true
  skip_credentials_validation = true
  skip_metadata_api_check     = true
  skip_requesting_account_id  = true  

  endpoints {
    s3             = "http://localstack:4566"
    iam            = "http://localstack:4566"
    sts            = "http://localstack:4566"
    ssm            = "http://localstack:4566"
    secretsmanager = "http://localstack:4566"
  }
}