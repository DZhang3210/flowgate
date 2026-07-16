resource "aws_security_group" "alb" {
    name = "${var.app_name}-${var.environment}-alb"
    description = "..."
    vpc_id = var.vpc_id

    ingress {
        from_port = 80
        to_port = 80
        protocol = "tcp"
        cidr_blocks = ["0.0.0.0/0"]
    }

    ingress {
        from_port = 443
        to_port = 443
        protocol = "tcp"
        cidr_blocks = ["0.0.0.0/0"]
    }

    egress{
        from_port   = 0
        to_port     = 0
        protocol    = "-1"
        cidr_blocks = ["0.0.0.0/0"]
    }
}

resource "aws_security_group" "ecs_api" {
    name = "${var.app_name}-${var.environment}-ecs-api"
    description = "..."
    vpc_id = var.vpc_id

    ingress {
        from_port = 3000
        to_port = 3000
        protocol = "tcp"
        security_groups = [aws_security_group.alb.id]
    }

    egress{
        from_port   = 0
        to_port     = 0
        protocol    = "-1"
        cidr_blocks = ["0.0.0.0/0"]
    }
}

resource "aws_security_group" "ecs_worker" {
    name = "${var.app_name}-${var.environment}-ecs-worker"
    description = "..."
    vpc_id = var.vpc_id

    egress{
        from_port   = 0
        to_port     = 0
        protocol    = "-1"
        cidr_blocks = ["0.0.0.0/0"]
    }
}

resource "aws_security_group" "rds" {
    name = "${var.app_name}-${var.environment}-rds"
    description = "..."
    vpc_id = var.vpc_id
    
    ingress {
        from_port = 5432
        to_port = 5432
        protocol = "tcp"
        security_groups = [aws_security_group.ecs_worker.id]
    }

    ingress {
        from_port = 5432
        to_port = 5432
        protocol = "tcp"
        security_groups = [aws_security_group.ecs_api.id]
    }

    egress{
        from_port   = 0
        to_port     = 0
        protocol    = "-1"
        cidr_blocks = ["0.0.0.0/0"]
    }
}

resource "aws_security_group" "redis" {
    name = "${var.app_name}-${var.environment}-redis"
    description = "..."
    vpc_id = var.vpc_id
    
    ingress {
        from_port = 6379
        to_port = 6379
        protocol = "tcp"
        security_groups = [aws_security_group.ecs_api.id]
    }

    egress{
        from_port   = 0
        to_port     = 0
        protocol    = "-1"
        cidr_blocks = ["0.0.0.0/0"]
    }
}

resource "aws_iam_role" "ecs_execution" {
  name               = "${var.app_name}-${var.environment}-ecs-execution"
  assume_role_policy = data.aws_iam_policy_document.ecs_assume_role.json
}

data "aws_iam_policy_document" "ecs_assume_role" {
  statement {
    effect  = "Allow"
    actions = ["sts:AssumeRole"]

    principals {
      type        = "Service"
      identifiers = ["ecs-tasks.amazonaws.com"]
    }
  }
}

resource "aws_iam_role_policy_attachment" "ecs_execution" {
  role       = aws_iam_role.ecs_execution.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AmazonECSTaskExecutionRolePolicy"
}

resource "aws_iam_role_policy" "ecs_execution_secrets" {
  name = "${var.app_name}-${var.environment}-ecs-execution-secrets"
  role = aws_iam_role.ecs_execution.id

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect   = "Allow"
        Action   = ["secretsmanager:GetSecretValue"]
        Resource = "*"
      }
    ]
  })
}




resource "aws_iam_role" "ecs_api" {
  name               = "${var.app_name}-${var.environment}-ecs-api"
  assume_role_policy = data.aws_iam_policy_document.ecs_assume_role.json
}

resource "aws_iam_role_policy" "ecs_api_secrets" {
  name = "${var.app_name}-${var.environment}-ecs-api-secrets"
  role = aws_iam_role.ecs_api.id

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect   = "Allow"
        Action   = ["sqs:SendMessage"]
        Resource = [var.sqs_queue_arn]
      }
    ]
  })
}



resource "aws_iam_role" "ecs_worker" {
  name               = "${var.app_name}-${var.environment}-ecs-worker"
  assume_role_policy = data.aws_iam_policy_document.ecs_assume_role.json
}

resource "aws_iam_role_policy" "ecs_worker_secrets" {
  name = "${var.app_name}-${var.environment}-ecs-worker-secrets"
  role = aws_iam_role.ecs_worker.id

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect   = "Allow"
        Action   = ["sqs:ReceiveMessage", "sqs:DeleteMessage"]
        Resource = [var.sqs_queue_arn]
      }
    ]
  })
}

resource "aws_iam_role" "flow_logs" {
  name               = "${var.app_name}-${var.environment}-vpc"
  assume_role_policy = data.aws_iam_policy_document.vpc_flow_logs_assume_role.json
}


data "aws_iam_policy_document" "vpc_flow_logs_assume_role" {
  statement {
    effect  = "Allow"
    actions = ["sts:AssumeRole"]

    principals {
      type        = "Service"
      identifiers = ["vpc-flow-logs.amazonaws.com"]
    }
  }
}

resource "aws_iam_role_policy" "vpc_flow_logs" {
  name = "${var.app_name}-${var.environment}-vpc-flow-logs"
  role = aws_iam_role.flow_logs.id

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect   = "Allow"
        Action   = ["logs:CreateLogStream","logs:PutLogEvents"]
        Resource = [var.vpc_flow_logs_arn]
      }
    ]
  })
}

data "aws_caller_identity" "current" {}

resource "aws_iam_role" "idle_scheduler" {
  name               = "${var.app_name}-${var.environment}-idle-scheduler"
  assume_role_policy = data.aws_iam_policy_document.idle_schedule_assume_role.json
}

data "aws_iam_policy_document" "idle_schedule_assume_role" {
  statement {
    effect  = "Allow"
    actions = ["sts:AssumeRole"]

    principals {
      type        = "Service"
      identifiers = ["lambda.amazonaws.com"]
    }
  }
}

resource "aws_iam_role_policy" "idle_scheduler" {
  name = "${var.app_name}-${var.environment}-idle-scheduler"
  role = aws_iam_role.idle_scheduler.id

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect   = "Allow"
        Action   = ["rds:DescribeDBInstances","rds:StartDBInstance", "rds:StopDBInstance"]
        Resource = [var.rds_arn]
      },
      {
        Effect   = "Allow"
        Action   = ["ecs:UpdateService", "ecs:DescribeServices"]
        Resource = ["arn:aws:ecs:${var.aws_region}:${data.aws_caller_identity.current.account_id}:service/${var.ecs_cluster_name}/*"]
      }
    ]
  })
}







resource "aws_secretsmanager_secret" "db_credentials" {
  name = "${var.app_name}-${var.environment}-db-credentials"
}

resource "aws_secretsmanager_secret_version" "db_credentials" {
  secret_id     = aws_secretsmanager_secret.db_credentials.id
  secret_string = jsonencode({
    username = "flowgate"
    password = "yourpasswordhere"
  })
  lifecycle {
    ignore_changes = [secret_string]
  }
}
