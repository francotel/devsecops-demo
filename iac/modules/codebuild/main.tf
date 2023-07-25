# CodeBuild IAM Role
resource "aws_iam_role" "role" {
  name               = "codebuild-role-${var.project}-${var.env}"
  assume_role_policy = data.aws_iam_policy_document.assume_policy.json
}

data "aws_iam_policy_document" "assume_policy" {
  statement {
    effect  = "Allow"
    actions = ["sts:AssumeRole"]
    principals {
      type        = "Service"
      identifiers = ["codebuild.amazonaws.com"]
    }
  }
}

resource "aws_iam_role_policy" "attach_policy" {
  name   = "codebuild-policy-${var.project}-${var.env}"
  role   = aws_iam_role.role.id
  policy = data.aws_iam_policy_document.policy.json
}

############# Creación CodeBuild Build ###############
resource "aws_codebuild_project" "build" {
  name           = "codebuild-build-${var.project}-${var.env}"
  build_timeout  = var.build_timeout
  service_role   = aws_iam_role.role.arn
  encryption_key = var.kms_id_artifact
  artifacts {
    type = var.artifacts
  }

  environment {
    compute_type    = var.compute_type
    image           = var.compute_image
    type            = var.compute_so
    privileged_mode = true

    environment_variable {
      name  = "S3_ARTIFACT_NAME"
      value = split(":", var.s3_artifact_arn)[5]
      type  = "PLAINTEXT"
    }

    dynamic "environment_variable" {
      for_each = var.env_codebuild_vars
      content {
        name  = environment_variable.key
        value = environment_variable.value
        type  = "PLAINTEXT"
      }
    }

    dynamic "environment_variable" {
      for_each = var.env_codebuild_resource_input
      content {
        name  = environment_variable.key
        value = environment_variable.value
        type  = "PLAINTEXT"
      }
    }

  }

  logs_config {
    cloudwatch_logs {
      group_name = aws_cloudwatch_log_group.loggroup_build.name
    }
  }

  source {
    type      = var.type_artifact
    buildspec = data.local_file.buildspec_local.content
  }

}

resource "aws_cloudwatch_log_group" "loggroup_build" {
  name              = format("/aws/codebuild/cb-build-%s-%s", var.project, var.env)
  retention_in_days = var.retention_in_days
}



