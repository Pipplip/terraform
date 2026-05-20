SHELL=/bin/bash

.PHONY: start stop tf-local-init tf-local-apply tf-local-destroy tf-init tf-apply tf-destroy

# Docker Compose commands
start:
	docker compose up -d

stop:
	docker compose down -v

# Terraform commands for local environment with localstack
tf-local-init:
	cd terraform_localstack && \
	docker compose run --rm terraform init

tf-local-apply:
	cd terraform_localstack && \
	docker compose run --rm terraform apply -auto-approve

tf-local-destroy:
	cd terraform_localstack && \
	docker compose run --rm terraform destroy -auto-approve

# terraform commands for general use
tf-init:
	cd terraform_general && \
	docker compose run --rm terraform init

tf-apply:
	cd terraform_general && \
	docker compose run --rm terraform apply -auto-approve

tf-destroy:
	cd terraform_general && \
	docker compose run --rm terraform destroy -auto-approve