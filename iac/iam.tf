# 1. Provedor OIDC já existente
data "aws_iam_openid_connect_provider" "oidc-git" {
  url = "https://token.actions.githubusercontent.com"
}

# 2. Blocos de IMPORT AUTOMÁTICO (O Terraform cuida da vinculação sozinho)
import {
  to = aws_iam_role.ecr_role
  id = "ecr-role"
}

import {
  to = aws_ecr_repository.devops_project
  id = "devops-project"
}

# 3. Repositório ECR
resource "aws_ecr_repository" "devops_project" {
  name                 = "devops-project"
  image_tag_mutability = "MUTABLE"

  image_scanning_configuration {
    scan_on_push = true
  }

  tags = {
    IAC = "True"
  }
}

# 4. Role IAM para GitHub Actions
resource "aws_iam_role" "ecr_role" {
  name = "ecr-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Principal = {
          Federated = data.aws_iam_openid_connect_provider.oidc-git.arn
        }
        Action = "sts:AssumeRoleWithWebIdentity"
        Condition = {
          StringEquals = {
            "token.actions.githubusercontent.com:aud" = "sts.amazonaws.com"
            "token.actions.githubusercontent.com:sub" = "repo:SamuelRodrigues29/devops-project:ref:refs/heads/master"
          }
        }
      }
    ]
  })

  managed_policy_arns = [
    "arn:aws:iam::aws:policy/AmazonEC2ContainerRegistryPowerUser"
  ]

  tags = {
    IAC = "True"
  }
}

