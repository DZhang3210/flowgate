data "tls_certificate" "github_actions" {
  url = "https://token.actions.githubusercontent.com"
}

resource "aws_iam_openid_connect_provider" "github" {
  url             = "https://token.actions.githubusercontent.com"
  client_id_list  = ["sts.amazonaws.com"]
  thumbprint_list = [data.tls_certificate.github_actions.certificates[0].sha1_fingerprint]
}

resource "aws_iam_role" "github_actions" {
  name               = "${var.app_name}-${var.environment}-github-actions"
  assume_role_policy = data.aws_iam_policy_document.github_actions_assume_role.json
}

resource "aws_iam_role_policy_attachment" "github_actions_admin" {
  role       = aws_iam_role.github_actions.name
  policy_arn = "arn:aws:iam::aws:policy/AdministratorAccess"
}

data "aws_iam_policy_document" "github_actions_assume_role" {
  statement {
    effect  = "Allow"
    actions = ["sts:AssumeRoleWithWebIdentity"]

    principals {
      type        = "Federated"
      identifiers = [aws_iam_openid_connect_provider.github.arn]
    }

    condition {
      test     = "StringEquals"
      variable = "token.actions.githubusercontent.com:aud"
      values   = ["sts.amazonaws.com"]
    }

    condition {
      test     = "StringEquals"
      variable = "token.actions.githubusercontent.com:sub"
      values   = ["repo:DZhang3210@53838139/flowgate@1302073667:ref:refs/heads/main"]
    }
  }
}

resource "aws_iam_role_policy" "github_actions" {
  name = "${var.app_name}-${var.environment}-github-actions"
  role = aws_iam_role.github_actions.id

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect   = "Allow"
        Action   = ["ecr:GetAuthorizationToken", "ecs:DescribeServices"]
        Resource = "*"
      },
       {
        Effect   = "Allow"
        Action   = ["ecr:BatchCheckLayerAvailability","ecr:InitiateLayerUpload", "ecr:UploadLayerPart", "ecr:CompleteLayerUpload", "ecr:PutImage"]
        Resource = [var.api_ecr_arn, var.worker_ecr_arn]
      },
      {
        Effect   = "Allow"
        Action   = ["ecs:UpdateService"]
        Resource = [var.api_ecs_arn, var.worker_ecs_arn]
      }
    ]})
}

