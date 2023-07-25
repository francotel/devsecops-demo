terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = ">= 4.9" # verifiy version on https://registry.terraform.io/providers/hashicorp/aws/latest
    }
  }

  required_version = ">= 1.2.0"

  backend "s3" {
  }
}