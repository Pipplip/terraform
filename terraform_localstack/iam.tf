data "aws_iam_policy_document" "app" {

  statement {
    actions = [
      "s3:PutObject",
      "s3:GetObject"
    ]

    resources = ["*"]
  }

  statement {
    actions = [
      "ssm:GetParameter"
    ]

    resources = ["*"]
  }

  statement {
    actions = [
      "secretsmanager:GetSecretValue"
    ]

    resources = ["*"]
  }
}