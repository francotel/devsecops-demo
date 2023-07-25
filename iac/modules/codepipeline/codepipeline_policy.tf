data "aws_iam_policy_document" "policy" {
  statement {
    actions = [
      "s3:GetObject",
      "s3:GetObjectVersion",
      "s3:GetBucketVersioning",
      "s3:PutObjectAcl",
      "s3:PutObject"
    ]
    resources = [
      var.s3_artifact_arn,
      "${var.s3_artifact_arn}/*"
    ]
  }
  statement {
    effect = "Allow"
    actions = [
      "codebuild:BatchGetBuilds",
      "codebuild:StartBuild"
    ]
    resources = [
      "arn:aws:codebuild:${var.region}:${var.aws_account_id}:project/*"
    ]
  }
  statement {
    actions = [
      "codestar-connections:UseConnection"
    ]
    resources = [
      "*"
    ]
  }

  statement {
    effect = "Allow"
    actions = [
      "kms:DescribeKey",
      "kms:GenerateDataKey*",
      "kms:CreateGrant",
      "kms:Encrypt",
      "kms:ReEncrypt*"
    ]
    resources = [
      "${var.kms_id_artifact}"
    ]
  }
  statement {
    effect = "Allow"
    actions = [
      "kms:GenerateDataKey",
      "kms:ListAliases",
      "kms:Decrypt"
    ]
    resources = [
      "*"
    ]
  }
  statement {
    effect = "Allow"
    actions = [
      "events:*"
    ]
    resources = [
      "*"
    ]
  }
  statement {
    effect    = "Allow"
    actions   = ["codestar-connections:UseConnection"]
    resources = [aws_codestarconnections_connection.github.arn]
  }
}