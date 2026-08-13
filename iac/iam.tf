# Provider already exists in this AWS account — reference it instead of creating it.
data "aws_iam_openid_connect_provider" "oidc-git" {
  url = "https://token.actions.githubusercontent.com"
}

import {
  to = aws_iam_role.ecr-role
  id = "ecr-role"
}

resource "aws_iam_role" "app-runner-role" {
  name = "app-runner-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow",
        Principal = {
          "Service" = "build.apprunner.amazonaws.com"
        }
        Action = "sts:AssumeRole"
      }
    ]
  })
  managed_policy_arns = [
    "arn:aws:iam::aws:policy/AmazonEC2ContainerRegistryReadOnly",
  ]
  tags = {
    IAC = "True"
  }
}


resource "aws_iam_role" "ecr-role" {
  name = "ecr-role"

  assume_role_policy = jsonencode({
    Statement = [
      {
        Action = "sts:AssumeRoleWithWebIdentity"
        Condition = {
          StringEquals = {
            "token.actions.githubusercontent.com:aud" = "sts.amazonaws.com"
            "token.actions.githubusercontent.com:sub" = "repo:SamuelRodrigues29/devops-project:ref:refs/heads/master"
          }
        }
        Effect = "Allow"
        Principal = {
          Federated = data.aws_iam_openid_connect_provider.oidc-git.arn
        }
      }
    ]
    Version = "2012-10-17"
  })
  tags = {
    IAC = "True"
  }
}