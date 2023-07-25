# CodePipeline IAM Role
resource "aws_iam_role" "role" {
  name               = "codepipeline-role-${var.project}-${var.env}"
  assume_role_policy = data.aws_iam_policy_document.assume_policy.json
}

data "aws_iam_policy_document" "assume_policy" {
  statement {
    effect  = "Allow"
    actions = ["sts:AssumeRole"]
    principals {
      type        = "Service"
      identifiers = ["codepipeline.amazonaws.com"]
    }
  }
}

resource "aws_iam_role_policy" "attach_policy" {
  name   = "codepipeline-policy-${var.project}-${var.env}"
  role   = aws_iam_role.role.id
  policy = data.aws_iam_policy_document.policy.json
}

resource "aws_codestarconnections_connection" "github" {
  name          = "github-connection"
  provider_type = "GitHub"
}

# CodePipeline
resource "aws_codepipeline" "codepipeline" {
  name     = "codepipeline-${var.project}-${var.env}"
  role_arn = aws_iam_role.role.arn

  artifact_store {
    location = var.s3_artifact_name
    type     = "S3"
    encryption_key {
      id   = var.kms_id_artifact
      type = "KMS"
    }
  }

  stage {
    name = "Source"

    action {
      name             = "Source"
      category         = "Source"
      owner            = "AWS"
      provider         = "CodeStarSourceConnection"
      version          = "1"
      output_artifacts = ["SourceArtifact"]

      configuration = {
        ConnectionArn    = aws_codestarconnections_connection.github.arn
        FullRepositoryId = "francotel/devsu-test"
        BranchName       = "main"
      }
    }
  }

  stage {
    name = "Build"

    action {
      name             = "Build"
      category         = "Build"
      owner            = "AWS"
      provider         = "CodeBuild"
      version          = "1"
      input_artifacts  = ["SourceArtifact"]
      output_artifacts = ["BuildArtifact"]

      configuration = {
        ProjectName = var.project_build
      }
    }
  }

  # stage {
  #   name = "Deploy"

  #   action {
  #     name             = "Build"
  #     category         = "Build"
  #     owner            = "AWS"
  #     provider         = "CodeBuild"
  #     version          = "1"
  #     input_artifacts  = ["SourceArtifact"]
  #     output_artifacts = ["DeployArtifact"]

  #     configuration = {
  #       ProjectName = format("cb-%s-%s-%s-deploy", var.tags.Project, var.service, var.tags.Env)
  #     }
  #   }
  # }
}

