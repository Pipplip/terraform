╔══════════════════════════════════════════════════════════════════════════════╗
║                         TERRAFORM INFRASTRUKTUR                             ║
╚══════════════════════════════════════════════════════════════════════════════╝

terraform.tf                    main.tf
┌─────────────────┐              ┌──────────────────────────────┐
│ AWS Provider    │────────────► │ provider "aws"               │
│ version 6.43.0  │  konfiguriert│ endpoints → localstack:4566  │
└─────────────────┘              └──────────────────────────────┘
│
│ alle API-Calls gehen hierüber
▼
┌─────────────────┐
│   LocalStack    │
│   :4566         │
└─────────────────┘


locals.tf
┌──────────────────────────────────────────────┐
│ env          = terraform.workspace           │◄── "test_euw1" (Makefile)
│ bucket_name  = "uploads-bucket-test-euw1"    │
│ resource_prefix ◄── SSM account_meta         │◄── muss vorab in LocalStack existieren
└──────────────────────────────────────────────┘
│
│ local.env / local.bucket_name / local.resource_prefix
│ wird referenziert von allen anderen Dateien
▼
╔══════════════════════════════════════════════════════════════════════════════╗
║                          RESSOURCEN (Apply-Reihenfolge)                     ║
╚══════════════════════════════════════════════════════════════════════════════╝

s3.tf                      ssm.tf                     secrets.tf
┌──────────────────┐        ┌───────────────────────┐   ┌─────────────────────────┐
│ aws_s3_bucket    │───────►│ aws_ssm_parameter     │   │ aws_secretsmanager      │
│ "uploads"        │  .arn  │ "bucket"              │   │ _secret "db"            │
│                  │        │ value = bucket.bucket │   │ name = env+"/app/db"    │
│ bucket_name      │        ├───────────────────────┤   ├─────────────────────────┤
│ = local.         │        │ aws_ssm_parameter     │   │ aws_secretsmanager      │
│   bucket_name    │        │ "db_host"             │   │ _secret_version "db"    │
└──────────────────┘        │ value = "postgres"    │   │ username = "app"        │
│                           └───────────────────────┘   │ password = "secret"     │
│                             │                         └─────────────────────────┘
│ .arn                        │ .arn                       │ .arn
│                             │                            │
▼                             ▼                            ▼
iam.tf
┌────────────────────────────────────────────────────────────────────────────┐
│                                                                            │
│  data "aws_iam_policy_document" "app"   ← nur im Speicher, keine Ressource │
│  ┌──────────────────────────────────────────────────────────────────────┐  │
│  │ s3:PutObject, s3:GetObject    → uploads-bucket-test-euw1/*           │  │
│  │ ssm:GetParameter              → /test_euw1/app/s3/bucket             │  │
│  │                               → /test_euw1/app/db/host               │  │
│  │ secretsmanager:GetSecretValue → test_euw1/app/database               │  │
│  └──────────────────────────────────────────────────────────────────────┘  │
│                │ .json                                                     │
│                ▼                                                           │
│  resource "aws_iam_policy" "app" ────────────────────────────────────┐     │
│                                                                      │     │
│  data "aws_iam_policy_document" "assume_role"                        │     │
│  ┌─────────────────────────────────────────┐                         │     │
│  │ sts:AssumeRole                          │                         │     │
│  │ principal: ecs-tasks.amazonaws.com      │                         │     │
│  └─────────────────────────────────────────┘                         │     │
│                │ .json                                               │     │
│                ▼                                                     │     │
│  resource "aws_iam_role" "app" ◄──────────────────────────────────── │     │
│                │                          aws_iam_role_policy_       │     │
│                └──────────────────────────attachment "app"───────────┘     │
└────────────────────────────────────────────────────────────────────────────┘


security_groups.tf                output.tf
┌──────────────────────┐          ┌───────────────────────────────────┐
│ aws_security_group   │          │ output "bucket"                   │
│ ingress: TCP 8080    │          │   ← aws_s3_bucket.uploads.bucket  │
│ egress:  alles       │          │ output "db_secret"                │
│ (in LocalStack ohne  │          │   ← aws_secretsmanager_secret     │
│  echte Wirkung)      │          │       .db.name                    │
└──────────────────────┘          └───────────────────────────────────┘


╔══════════════════════════════════════════════════════════════════════════════╗
║                         GO ANWENDUNG (main.go)                              ║
╚══════════════════════════════════════════════════════════════════════════════╝

                    ┌─────────────────────────────────────┐
                    │           main.go                   │
                    │                                     │
                    │  NewConfig()                        │
                    │    → AWS SDK mit LocalStack-URL     │
                    │          │                          │
                    │          ├── ssmClient              │
                    │          ├── secretsClient          │
                    │          └── s3Client               │
                    └─────────────────────────────────────┘
                         │              │             │
                         ▼              ▼             ▼
              ┌──────────────┐  ┌────────────┐  ┌──────────┐
              │ SSM lesen    │  │ Secret     │  │ S3       │
              │              │  │ lesen      │  │ Upload   │
              │ GetParameter │  │            │  │          │
              │ /env/app/    │  │ GetSecret  │  │ PutObject│
              │   s3/bucket  │  │ env/app/   │  │          │
              │ /env/app/    │  │   database │  │          │
              │   db/host    │  │            │  │          │
              └──────┬───────┘  └─────┬──────┘  └────┬─────┘
                     │                │               │
                     ▼                ▼               │
              ┌─────────────────────────────┐         │
              │  bucket-name, db-host       │         │
              │  username, password         │         │
              │          │                  │         │
              │          ▼                  │         │
              │  postgres://user:pw@host/db │         │
              │          │                  │         │
              │          ▼                  │         │
              │  database.Connect()         │         │
              └─────────────────────────────┘         │
                         │                            │
                         ▼                            ▼
              ┌──────────────┐              ┌─────────────────┐
              │  PostgreSQL  │◄─────────────│ UploadHandler   │
              │  :5432       │  INSERT      │ POST /upload    │
              │  (Docker)    │  Metadaten   │                 │
              └──────────────┘              └─────────────────┘
                                                     │
                                                     │ PutObject
                                                     ▼
                                            ┌─────────────────┐
                                            │ S3 Bucket       │
                                            │ uploads-bucket- │
                                            │ test-euw1       │
                                            │ (LocalStack)    │
                                            └─────────────────┘


╔══════════════════════════════════════════════════════════════════════════════╗
║                    IAM-PRÜFUNG BEI JEDEM API-CALL (echtes AWS)              ║
╚══════════════════════════════════════════════════════════════════════════════╝

App-Request                AWS IAM prüft                  Ergebnis
─────────────────────────────────────────────────────────────────────
ssm:GetParameter           Rolle hat Policy?  ✅           → Wert zurück
/test_euw1/app/s3/bucket ARN in Policy?     ✅

ssm:GetParameter           Rolle hat Policy?  ✅           → ❌ AccessDenied
/test_euw1/app/OTHER     ARN in Policy?     ❌

secretsmanager:GetSecret   Rolle hat Policy?  ✅           → Secret zurück
test_euw1/app/database   ARN in Policy?     ✅

s3:PutObject               Rolle hat Policy?  ✅           → Upload OK
uploads-bucket-test-euw1 ARN in Policy?     ✅

s3:DeleteBucket            Rolle hat Policy?  ❌           → ❌ AccessDenied
uploads-bucket-test-euw1 Aktion in Policy?  ❌ (nur Put/Get)