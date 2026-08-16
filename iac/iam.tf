# Gerencia o provider OIDC — client_id_list precisa incluir sts.amazonaws.com
resource "aws_iam_openid_connect_provider" "github" {
  url            = "https://token.actions.githubusercontent.com"
  client_id_list = ["sts.amazonaws.com"]

  # AWS ignora o thumbprint para GitHub desde 2023, mas o campo ainda é obrigatório
  thumbprint_list = ["6938fd4d98bab03faadb97b34396831e3780aea1"]

  tags = {
    IAC = "True"
  }
}

import {
  to = aws_iam_role.ecr_role
  id = "ecr-role"
}

resource "aws_iam_role" "ecr_role" {
  name = "ecr-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Principal = {
          Federated = aws_iam_openid_connect_provider.github.arn
        }
        Action = "sts:AssumeRoleWithWebIdentity"
        Condition = {
          StringEquals = {
            "token.actions.githubusercontent.com:aud" = "sts.amazonaws.com"
          }
          StringLike = {
            # Aceita formato clássico e imutável (repos novos / opt-in no GitHub)
            "token.actions.githubusercontent.com:sub" = [
              "repo:SamuelRodrigues29/devops-project:*",
              "repo:SamuelRodrigues29@141246622/devops-project@1316030481:*"
            ]
          }
        }
      }
    ]
  })

  tags = {
    IAC = "True"
  }
}

resource "aws_iam_role_policy" "ecr_role_policy" {
  name = "ecr-app-permission"
  role = aws_iam_role.ecr_role.id

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Action = [
          "ecr:GetAuthorizationToken",
          "ecr:BatchCheckLayerAvailability",
          "ecr:GetDownloadUrlForLayer",
          "ecr:GetRepositoryPolicy",
          "ecr:DescribeRepositories",
          "ecr:ListImages",
          "ecr:DescribeImages",
          "ecr:BatchGetImage",
          "ecr:GetLifecyclePolicy",
          "ecr:GetLifecyclePolicyPreview",
          "ecr:ListTagsForResource",
          "ecr:DescribeImageScanFindings",
          "ecr:InitiateLayerUpload",
          "ecr:UploadLayerPart",
          "ecr:CompleteLayerUpload",
          "ecr:PutImage"
        ]
        Resource = "*"
      }
    ]
  })
}
