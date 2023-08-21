data "local_file" "buildspec_local" {
  filename = "./configs/cicd-conf/${var.buildspec_file}"
}

variable "aws_account_id" {
  type        = string
  description = "AWS Account ID number of the account."
}

variable "region" {
  type        = string
  description = "The AWS region."
}

variable "project" {
  type        = string
  description = "Name of project"
}

variable "env" {
  type        = string
  description = "Name of environment"
}

variable "kms_id_artifact" {
}

variable "s3_artifact_arn" {
}

variable "retention_in_days" {
}

# # variable "branch_name" {
# # }

variable "artifacts" {
  type        = string
  description = "Campo para artefactos"
}

variable "build_timeout" {
  type        = number
  description = "Timeout de ejecución para el proyecto"
}

variable "compute_type" {
  type        = string
  description = "Tipo de imagen para compilar"
}

variable "compute_image" {
  type        = string
  description = "Imagen a usar para compilar artefactos"
}

variable "compute_so" {
  type        = string
  description = "SO para compilar los artefactos"
}

variable "type_artifact" {
  type = string
}

variable "buildspec_file" {
}

variable "env_codebuild_tfvars" {
}

variable "env_codebuild_resource_input" {
}
