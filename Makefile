SHELL=/bin/bash

.PHONY: start stop ls-s3 show-current-workspace list-workspaces create-workspace select-workspace show-applied-infra show-output tf-local-init tf-local-apply tf-local-destroy tf-init tf-apply tf-destroy

# Docker Compose commands
start:
	docker compose up -d

stop:
	docker compose down -v

ls-s3:
	AWS_ACCESS_KEY_ID=test \
	AWS_SECRET_ACCESS_KEY=test \
	AWS_SESSION_TOKEN=test \
	aws --endpoint-url=http://localhost:4566 s3 ls

show-current-workspace:
	docker compose run --rm terraform-local workspace show

list-workspaces:
	docker compose run --rm terraform-local workspace list

# Aufruf "make create-workspace NAME=test_euw1"
create-workspace:
	docker compose run --rm terraform-local workspace new $(NAME)

# Aufruf "make select-workspace NAME=test_euw1"
select-workspace:
	docker compose run --rm terraform-local workspace select $(NAME)

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