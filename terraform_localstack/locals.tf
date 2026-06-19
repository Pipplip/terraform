# locals sind eine Sammlung an zentralen Variablen, die in der gesamten Terraform-Konfiguration verwendet werden können.
locals {
  service_name       = "upload-service"
  service_name_kebab = replace(local.service_name, "_", "-")
  service_name_snake = replace(local.service_name, "-", "_")
  #env               = local.account_meta_json.environment_type
  env         = terraform.workspace
  bucket_name = "uploads-bucket-${replace(local.env, "_", "-")}"
}