SHELL=/bin/bash
-include .env
export NAME

.PHONY: start stop start-all build-app ls-s3 ls-s3-win show-current-workspace list-workspaces create-workspace select-workspace show-applied-infra show-output tf-local-init tf-local-apply tf-local-destroy tf-init tf-apply tf-destroy

# -------- Docker commands ----------- #
start:
	docker compose up -d

stop:
	docker compose down -v

start-all:
	docker compose up -d localstack
	docker compose run --rm terraform-local init
	docker compose run --rm terraform-local plan
	docker compose run --rm terraform-local apply -auto-approve
	docker compose up -d --build app

# -------- app service commands ----------- #
# nur lokales bauen der App - nicht notwendig, da die App automatisch im docker compose gebaut wird, wenn sie mit "start-all" gestartet wird
build-app:
	docker build -t aws-learning-service ./app

ls-s3:
	AWS_ACCESS_KEY_ID=test \
	AWS_SECRET_ACCESS_KEY=test \
	AWS_SESSION_TOKEN=test \
	aws --endpoint-url=http://localhost:4566 s3 ls

ls-s3-win:
	docker compose exec localstack awslocal s3 ls s3://uploads-bucket-$(NAME)

# -------- terraform commands ----------- #
show-current-workspace:
	docker compose run --rm terraform-local workspace show

list-workspaces:
	docker compose run --rm terraform-local workspace list

# Aufruf "make create-workspace NAME=test_euw1"
create-workspace:
	docker compose run --rm terraform-local workspace new $(NAME)
	echo NAME=$(NAME) > .env

# Aufruf "make select-workspace NAME=test_euw1"
select-workspace:
	docker compose run --rm terraform-local workspace select $(NAME)
	echo NAME=$(NAME) > .env

# Terraform commands for local environment with localstack
## Gebe alle Services aus, die in Terraform definiert sind und bereits angewendet wurden
show-applied-infra:
	docker compose run --rm terraform-local state list

## gibt die Outputs aus, die in output.tf definiert sind, z.B. die S3 Bucket Namen
show-output:
	docker compose run --rm terraform-local output

tf-local-init:
	docker compose run --rm terraform-local init

tf-local-plan:
	docker compose run --rm terraform-local plan

tf-local-apply:
	docker compose run --rm terraform-local apply -auto-approve

tf-local-destroy:
	docker compose run --rm terraform-local destroy -auto-approve

# terraform commands for general use
tf-init:
	docker compose run --rm terraform -chdir=terraform_general init

tf-plan:
	docker compose run --rm terraform -chdir=terraform_general plan

tf-apply:
	docker compose run --rm terraform -chdir=terraform_general apply -auto-approve

tf-destroy:
	docker compose run --rm terraform -chdir=terraform_general destroy -auto-approve