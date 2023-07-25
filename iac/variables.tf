variable "aws_account_id" {
  type        = string
  description = "AWS Account ID number of the account."
}

variable "aws_region" {
  type        = string
  description = "The AWS region."
}

variable "env" {
  type        = string
  description = "Environment name."
}

variable "profile" {
  description = "AWS environment account"
  type        = string
}

variable "project" {
  description = "Project Name or service"
  type        = string
}

variable "owner" {
  description = "Owner Name or service"
  type        = string
}

variable "cost" {
  description = "Center of cost"
  type        = string
}

variable "tf_version" {
  description = "Terraform version that used for the project"
  type        = string
}

### CODEBUILD VARIABLES  ####
variable "env_codebuild_vars" {
  default = {
  }
}

##### SNYK VARIABLES   #####
# variable "snyk_token" {
# }
# variable "snyk_org" {
# }
# variable "sonar_token" {
# }