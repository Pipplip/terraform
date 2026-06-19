# erzeugt IAM-Policies als Json
# regelt wer was darf

# Deine App bekommt eine Identität (IAM Role)
# → an dieser Identität hängt eine Liste von Erlaubnissen (Policy)
# → AWS prüft diese Liste bei jedem API-Aufruf

# definiert Erlaubnisse als Json im Speicher (keine AWS Ressource)
# also was darf gemacht werden und auf was
data "aws_iam_policy_document" "app" {
  statement {
    actions   = ["s3:PutObject", "s3:GetObject"]
    resources = ["${aws_s3_bucket.uploads.arn}/*"] # nur der eigene Bucket
  }

  statement {
    actions = ["ssm:GetParameter"]
    resources = [
      aws_ssm_parameter.bucket.arn,
      aws_ssm_parameter.db_host.arn,
    ]
  }

  statement {
    actions   = ["secretsmanager:GetSecretValue"]
    resources = [aws_secretsmanager_secret.db.arn]
  }
}

# definiert, wer die Rolle annehmen darf - hier nur ECS tasks
# Stell dir vor, eine Rolle ist ein Schlüssel.
# Die assume_role_policy ist das Schloss – nur wer reinpasst, darf den Schlüssel benutzen.
# Hier darf nur der ECS-Service diese Rolle annehmen.
# Ein Lambda, ein EC2 oder ein Nutzer könnten das nicht – selbst wenn sie es versuchen,
# sagt AWS -> AccessDenied.
data "aws_iam_policy_document" "assume_role" {
  statement {
    actions = ["sts:AssumeRole"]
    principals {
      type        = "Service"
      identifiers = ["ecs-tasks.amazonaws.com"]
    }
  }
}

# Die Rolle selbst (Identität) als echte Resource in AWS
# = die Identität, die der ECS Task annimmt
resource "aws_iam_role" "app" {
  name               = "${local.service_name}-app-role"
  assume_role_policy = data.aws_iam_policy_document.assume_role.json
}

# Die Policy, die die Erlaubnisse definiert, als echte Resource in AWS
resource "aws_iam_policy" "app" {
  name   = "${local.service_name}-app-policy"
  policy = data.aws_iam_policy_document.app.json
}

# verknüpft die Rolle mit der Policy, damit die Erlaubnisse wirksam werden
resource "aws_iam_role_policy_attachment" "app" {
  role       = aws_iam_role.app.name
  policy_arn = aws_iam_policy.app.arn
}