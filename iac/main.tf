data "aws_caller_identity" "current" {}
data "aws_region" "current" {}

locals {
  aws_account_id = data.aws_caller_identity.current.account_id
  aws_region     = data.aws_region.current.name
}

module "kms" {
  source = "terraform-aws-modules/kms/aws"

  description = "KMS for devsecops-demo"
  key_usage   = "ENCRYPT_DECRYPT"

  # Policy

  # Aliases
  aliases = ["devsecops-demo/${var.env}"]

  tags = {
    Alias = "devsecops-demo/${var.env}"
  }
}

module "ecr" {
  source = "terraform-aws-modules/ecr/aws"

  repository_name            = "ecr-${var.project}-${var.env}"
  repository_encryption_type = "KMS"
  repository_kms_key         = module.kms.key_arn
  repository_type            = "private"


  # repository_read_write_access_arns = ["arn:aws:iam::012345678901:role/terraform"]
  repository_lifecycle_policy = jsonencode({
    rules = [
      {
        rulePriority = 1,
        description  = "Keep last 30 images",
        selection = {
          tagStatus     = "tagged",
          tagPrefixList = ["v"],
          countType     = "imageCountMoreThan",
          countNumber   = 30
        },
        action = {
          type = "expire"
        }
      }
    ]
  })

  tags = {
    Name = "ecr-${var.project}-${var.env}"
  }
}

######   S3 ARTIFACT RESOURCES   ######
module "s3_bucket_artifact" {
  source = "terraform-aws-modules/s3-bucket/aws"

  bucket                                = "s3-artifacts-${var.project}-${local.aws_region}-${var.env}"
  attach_deny_insecure_transport_policy = true
  attach_require_latest_tls_policy      = true

  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = true
  restrict_public_buckets = true

  versioning = {
    enabled = false
  }

  server_side_encryption_configuration = {
    rule = {
      apply_server_side_encryption_by_default = {
        kms_master_key_id = module.kms.key_arn
        sse_algorithm     = "aws:kms"
      }
    }
  }

  lifecycle_rule = [
    {
      id      = "artifact"
      enabled = true

      transition = [
        {
          days          = 30
          storage_class = "ONEZONE_IA"
        },
        {
          days          = 90
          storage_class = "GLACIER"
        },
        {
          days          = 180
          storage_class = "DEEP_ARCHIVE"
        }
      ]
      expiration = {
        days = 365
      }
    }
  ]
}

#####   S3 UPLOAD CONFIGURATIONS   ######
resource "aws_s3_object" "object" {
  depends_on = [
    module.s3_bucket_artifact
  ]
  for_each    = fileset("./configs/cicd-conf/", "**")
  bucket      = module.s3_bucket_artifact.s3_bucket_id
  key         = "cicd-conf/${each.value}"
  source      = "./configs/cicd-conf/${each.value}"
  source_hash = md5(file("./configs/cicd-conf/${each.value}"))
}

# resource "aws_s3_object" "manifests" {
#   depends_on = [
#     module.s3_bucket_artifact
#   ]
#   for_each    = fileset("./configs/manifests/", "**")
#   bucket      = module.s3_bucket_artifact.s3_bucket_id
#   key         = "manifests/${each.value}"
#   source      = "./configs/manifests/${each.value}"
#   source_hash = md5(file("./configs/manifests/${each.value}"))
# }


# #######   CODEBUILD RESOURCES   ######
module "codebuild_app" {
  source          = "./modules/codebuild"
  project         = var.project
  aws_account_id  = local.aws_account_id
  region          = local.aws_region
  env             = var.env
  kms_id_artifact = module.kms.key_arn
  build_timeout   = 60
  compute_type    = "BUILD_GENERAL1_SMALL"
  compute_image   = "aws/codebuild/standard:6.0"
  compute_so      = "LINUX_CONTAINER"
  buildspec_file  = "buildspec.yaml"
  s3_artifact_arn = module.s3_bucket_artifact.s3_bucket_arn
  artifacts       = "CODEPIPELINE"
  type_artifact   = "CODEPIPELINE"

  ## ADD ENV VARIABLES TO CODEBUILD FROM TFVARS  ##
  env_codebuild_tfvars = var.env_codebuild_vars
  env_codebuild_resource_input = {
    ENV_CB_ECR_URL      = module.ecr.repository_url
    ENV_CB_ENV          = var.env
    ENV_CB_S3_ARTIFACTS = module.s3_bucket_artifact.s3_bucket_id
  }
  retention_in_days = 30

}

#######   CODEPIPELINE RESOURCES   ######
module "codepipeline_app" {
  source            = "./modules/codepipeline"
  project           = var.project
  aws_account_id    = local.aws_account_id
  region            = local.aws_region
  env               = var.env
  kms_id_artifact   = module.kms.key_arn
  repository_name   = "francotel/devsecops-demo"
  repository_branch = "main"

  s3_artifact_arn  = module.s3_bucket_artifact.s3_bucket_arn
  s3_artifact_name = module.s3_bucket_artifact.s3_bucket_id

  project_build = module.codebuild_app.build_name
}