# 1. Provedor OIDC do GitHub já existente
data "aws_iam_openid_connect_provider" "oidc-git" {
  url = "https://token.actions.githubusercontent.com"
}

# 2. Criação do Repositório ECR
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

# 3. Role IAM para o GitHub Actions
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
            "token.actions.githubusercontent.com:sub" = "repo:https://github.com/SamuelRodrigues29/devops-project:ref:refs/heads/master"
          }
        }
      }
    ]
  })

  # Permissão padrão para ler, autenticar, criar tags e publicar no ECR
  managed_policy_arns = [
    "arn:aws:iam::aws:policy/AmazonEC2ContainerRegistryPowerUser"
  ]

  tags = {
    IAC = "True"
  }
}