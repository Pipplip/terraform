terraform {
  # definiere die benötigten Provider und deren Versionen
  # Provider = Software, die Terraform verwendet, um mit verschiedenen Cloud-Anbietern oder Diensten zu interagieren. 
  # In diesem Fall ist es der AWS-Provider, der es Terraform ermöglicht, Ressourcen in Amazon Web Services zu erstellen und zu verwalten.
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "=6.43.0"
    }
  }

  # definiere die minimale Terraform-Version, die für dieses Projekt erforderlich ist
  required_version = ">= 1.2"
}