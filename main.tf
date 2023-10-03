terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
  }
}

# Configure the AWS Provider
provider "aws" {
  region     = var.aws-region
  access_key = var.aws-access-key
  secret_key = var.aws-secret-key
}

#Configure the AWS ECR Provider for API
resource "aws_ecr_repository" "population-analyzer-api-repo" {
  name = "population-analyzer-api-repo"
}

#Configure the AWS ECR Provider for DB
resource "aws_ecr_repository" "population-analyzer-db-repo" {
  name = "population-analyzer-db-repo"
}

#Configure the AWS KMS Key
resource "aws_kms_key" "kms-key" {
  description             = "kms-key"
  deletion_window_in_days = 7
}

#Configure the AWS Cloudwatch Log Group
resource "aws_cloudwatch_log_group" "population-analyzer" {
  name = "population-analyzer"
}

#Configure the AWS ECS Cluster
resource "aws_ecs_cluster" "population-analyzer" {
  name = "population-analyzer"

  configuration {
    execute_command_configuration {
      kms_key_id = aws_kms_key.kms-key.arn
      logging    = "OVERRIDE"

      log_configuration {
        cloud_watch_encryption_enabled = true
        cloud_watch_log_group_name     = aws_cloudwatch_log_group.population-analyzer.name
      }
    }
  }
}

#Configure the AWS Task to run the API and DB on the same container
resource "aws_ecs_task_definition" "population-analyzer" {
  family                = "population-analyzer"
  container_definitions = jsonencode([
    {
      name      = "api"
      image     = "${aws_ecr_repository.population-analyzer-api-repo.repository_url}:latest"
      essential = true
      portMappings = [
        {
          containerPort = 3000,
          hostPort      = 3000
        }
      ],
      logConfiguration = {
        logDriver = "awslogs",
        options: {
          awslogs-create-group  = "true",
          awslogs-group         = aws_cloudwatch_log_group.population-analyzer.name,
          awslogs-region        = var.aws-region,
          awslogs-stream-prefix = "awslogs-population-analyzer-api"
        }
      },
      dependsOn = [
        {
          containerName = "db",
          condition = "HEALTHY"
        }
      ]
    },
    {
      name      = "db",
      image     = "${aws_ecr_repository.population-analyzer-db-repo.repository_url}:latest",
      essential = true,
      portMappings = [
        {
          containerPort = 5433,
          hostPort      = 5433
        }
      ],
      logConfiguration = {
        logDriver = "awslogs",
        options: {
          awslogs-create-group  = "true",
          awslogs-group         = aws_cloudwatch_log_group.population-analyzer.name,
          awslogs-region        = var.aws-region,
          awslogs-stream-prefix = "awslogs-population-analyzer-db"
        }
      },
      environment = [
        {
          name = "POSTGRES_PASSWORD",
          value = var.postgres_password
        },
        {
          name = "POSTGRES_DB",
          value = var.postgres_database
        }
      ],
      healthCheck = {
        command = [
          "CMD-SHELL", "pg_isready -U postgres"
        ],
        interval = 300,
      }
    }
  ])
  cpu                      = 256
  memory                   = 1024
  requires_compatibilities = ["FARGATE"]
  execution_role_arn       = aws_iam_role.ecs-task-execution-role.arn
  network_mode             = "awsvpc"
}

#Configure the AWS IAM Role for ECS Task Execution
resource "aws_iam_role" "ecs-task-execution-role" {
  name                = "ecs-task-execution-role"
  assume_role_policy  = data.aws_iam_policy_document.ecs-task-assume-role-policy.json
  managed_policy_arns = [aws_iam_policy.ecs-task-execution-policy.arn]
}

#Configure the AWS IAM Policy document for ECS Task Execution
data "aws_iam_policy_document" "ecs-task-assume-role-policy" {
  statement {
    actions = [
      "sts:AssumeRole",
    ]

    principals {
      type        = "Service"
      identifiers = ["ecs-tasks.amazonaws.com"]
    }
  }
}

#Configure the AWS IAM Policy for ECS Task Execution
resource "aws_iam_policy" "ecs-task-execution-policy" {
  name      = "ecs-task-execution-policy"
  policy    = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = [
          "logs:CreateLogStream",
          "ecr:BatchCheckLayerAvailability",
          "ecr:BatchGetImage",
          "ecr:CompleteLayerUpload",
          "ecr:GetDownloadUrlForLayer",
          "ecr:InitiateLayerUpload",
          "ecr:PutImage",
          "ecr:UploadLayerPart",
          "ecr:GetAuthorizationToken"
        ]
        Effect   = "Allow"
        Resource = "*"
      },
    ]
  })
}

#Configure the AWS ECS Service
resource "aws_ecs_service" "population-analyzer" {
  name            = "population-analyzer"
  cluster         = aws_ecs_cluster.population-analyzer.id
  task_definition = aws_ecs_task_definition.population-analyzer.arn
  launch_type     = "FARGATE"
  desired_count   = 1
  network_configuration {
    subnets          = [aws_default_subnet.default-subnet.id]
    assign_public_ip = true
  }
}

#Configure the AWS Default Subnet
resource "aws_default_subnet" "default-subnet" {
  availability_zone = "us-east-1a"
}