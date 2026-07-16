resource "aws_ecr_repository" "api" {
    name = "${var.app_name}-api"
}

resource "aws_ecr_repository" "worker" {
    name = "${var.app_name}-worker"
}

resource "aws_ecs_cluster" "main" {
  name = "${var.app_name}-${var.environment}"
}
resource "aws_cloudwatch_log_group" "api"{
    name = "/ecs/${var.app_name}-api"
}

resource "aws_ecs_task_definition" "api" {
  family                   = "${var.app_name}-api"
  network_mode             = "awsvpc"
  requires_compatibilities = ["FARGATE"]
  cpu                      = var.api_cpu
  memory                   = var.api_memory
  execution_role_arn       = var.execution_role_arn
  task_role_arn            = var.api_task_role_arn

  container_definitions = jsonencode([
    {
        name = "${var.app_name}-api"
        image = "${aws_ecr_repository.api.repository_url}:${var.image_tag}"
        essential = true
        
        portMappings = [{
            containerPort = 3000
            protocol = "tcp"
        }]

        environment = [
            {name = "NODE_ENV", value = var.environment},
            {name = "DB_HOST", value = var.db_host},
            {name = "DB_PORT", value = tostring(var.db_port)},
            {name = "DB_NAME", value = "${var.app_name}_${var.environment}_rds"},
            {name = "REDIS_HOST", value = var.redis_host},
            {name = "REDIS_PORT", value = tostring(var.redis_port)},
            {name = "QUEUE_DRIVER", value = "sqs"},
            {name = "QUEUE_NAME", value = "${var.app_name}-${var.environment}-sqs-queue"},
            {name = "SQS_QUEUE_URL", value = var.sqs_queue_url}
        ]
        secrets = [
            { name = "DB_USER", valueFrom = "${var.secret_manager_arn}:username::"},
            { name = "DB_PASSWORD", valueFrom = "${var.secret_manager_arn}:password::" }
        ]

        logConfiguration = {
            logDriver = "awslogs"
            options = {
                "awslogs-group" = aws_cloudwatch_log_group.api.name
                "awslogs-region" = var.aws_region
                "awslogs-stream-prefix" = "ecs"
            }
        }
    }
  ])
}

resource "aws_cloudwatch_log_group" "worker"{
    name = "/ecs/${var.app_name}-worker"
}

resource "aws_ecs_task_definition" "worker" {
  family                   = "${var.app_name}-worker"
  network_mode             = "awsvpc"
  requires_compatibilities = ["FARGATE"]
  cpu                      = var.worker_cpu
  memory                   = var.worker_memory
  execution_role_arn       = var.execution_role_arn
  task_role_arn            = var.worker_task_role_arn

  container_definitions = jsonencode([
    {
        name = "${var.app_name}-worker"
        image = "${aws_ecr_repository.worker.repository_url}:${var.image_tag}"
        essential = true
        command = ["node", "src/worker.js"]

        environment = [
            {name = "NODE_ENV", value = var.environment},
            {name = "REDIS_HOST", value = var.redis_host},
            {name = "REDIS_PORT", value = tostring(var.redis_port)},
            {name = "QUEUE_DRIVER", value = "sqs"},
            {name = "QUEUE_NAME", value = "${var.app_name}-${var.environment}-sqs-queue"},
            {name = "SQS_QUEUE_URL", value = var.sqs_queue_url}
        ]

        logConfiguration = {
            logDriver = "awslogs"
            options = {
                "awslogs-group" = aws_cloudwatch_log_group.worker.name
                "awslogs-region" = var.aws_region
                "awslogs-stream-prefix" = "ecs"
            }
        }
    }
  ])
}

resource "aws_lb" "main"{
    name = "${var.app_name}-${var.environment}"
    internal = false
    load_balancer_type = "application"
    security_groups = [var.alb_security_group_id]
    subnets = var.public_subnet_ids
}

resource "aws_lb_target_group" "api" {
    name = "${var.app_name}-api-${var.environment}"
    port = 3000
    protocol = "HTTP"
    vpc_id = var.vpc_id
    target_type = "ip"

    health_check { 
        path    = "/health"
        matcher = "200"
    }
}

resource "aws_lb_listener" "http" {
    load_balancer_arn = aws_lb.main.arn
    port = 80
    protocol = "HTTP"

    default_action {
      type = "forward"
      target_group_arn = aws_lb_target_group.api.arn
    }
}

#TODO: Reenable this once we get a certificate arn
# resource "aws_lb_listener" "https" {
#     load_balancer_arn = aws_lb.main.arn
#     port = 443
#     protocol = "HTTPS"
#     certificate_arn = var.certificate_arn

#     default_action {
#       type = "forward"
#       target_group_arn = aws_lb_target_group.api.arn
#     }
# }

resource "aws_ecs_service" "api" {
  name            = "${var.app_name}-api"
  cluster         = aws_ecs_cluster.main.id
  task_definition = aws_ecs_task_definition.api.arn
  desired_count   = var.api_desired_count
  launch_type     = "FARGATE"

  load_balancer {
    target_group_arn = aws_lb_target_group.api.arn
    container_name = "${var.app_name}-api"
    container_port = 3000
  }

  network_configuration {
    subnets =  var.private_subnet_ids
    assign_public_ip = false
    security_groups = [var.ecs_api_security_group_id]
  }
}

resource "aws_ecs_service" "worker" {
  name            = "${var.app_name}-worker"
  cluster         = aws_ecs_cluster.main.id
  task_definition = aws_ecs_task_definition.worker.arn
  desired_count   = var.worker_desired_count
  launch_type     = "FARGATE"

  network_configuration {
    subnets =  var.private_subnet_ids
    assign_public_ip = false
    security_groups = [var.ecs_worker_security_group_id]
  }
}

resource "aws_appautoscaling_target" "worker" {
  max_capacity       = 10
  min_capacity       = 1
  resource_id        = "service/${aws_ecs_cluster.main.name}/${aws_ecs_service.worker.name}"
  scalable_dimension = "ecs:service:DesiredCount"
  service_namespace  = "ecs"
}

resource "aws_appautoscaling_policy" "worker_scale_up" {
  name               = "worker-scale-up-on-queue-depth"
  policy_type        = "StepScaling"
  resource_id        = aws_appautoscaling_target.worker.resource_id
  scalable_dimension = aws_appautoscaling_target.worker.scalable_dimension
  service_namespace  = aws_appautoscaling_target.worker.service_namespace

  step_scaling_policy_configuration {
    adjustment_type = "ChangeInCapacity"
    # Low queue depth: add 1 worker
    step_adjustment {
      scaling_adjustment          = 1
      metric_interval_lower_bound = 0
      metric_interval_upper_bound = 100
    }
    # Medium queue depth: add 3 workers
    step_adjustment {
      scaling_adjustment          = 3
      metric_interval_lower_bound = 100
      metric_interval_upper_bound = 1000
    }
    # High queue depth: add 5 workers
    step_adjustment {
      scaling_adjustment          = 5
      metric_interval_lower_bound = 1000
    }
  }
}

resource "aws_appautoscaling_policy" "worker_scale_down" {
  name               = "worker-scale-down-on-queue-depth"
  policy_type        = "StepScaling"
  resource_id        = aws_appautoscaling_target.worker.resource_id
  scalable_dimension = aws_appautoscaling_target.worker.scalable_dimension
  service_namespace  = aws_appautoscaling_target.worker.service_namespace

  step_scaling_policy_configuration {
    adjustment_type = "ChangeInCapacity"
    step_adjustment {
      scaling_adjustment          = -1
      metric_interval_upper_bound = 0
    }
  }
}

resource "aws_cloudwatch_metric_alarm" "worker_queue_depth_high" {
    alarm_name          = "${var.app_name}-worker-queue-depth-high"
    namespace           = "AWS/SQS"
    comparison_operator = "GreaterThanThreshold"
    threshold           = 5
    evaluation_periods  = 2
    period              = 60
    statistic           = "Maximum"
    metric_name         = "ApproximateNumberOfMessagesVisible"
    dimensions          = { QueueName = var.sqs_queue_name }
    alarm_actions       = [aws_appautoscaling_policy.worker_scale_up.arn]
}

resource "aws_cloudwatch_metric_alarm" "worker_queue_depth_low" {
    alarm_name          = "${var.app_name}-worker-queue-depth-low"
    namespace           = "AWS/SQS"
    comparison_operator = "LessThanOrEqualToThreshold"
    threshold           = 1
    evaluation_periods  = 5
    period              = 60
    statistic           = "Maximum"
    metric_name         = "ApproximateNumberOfMessagesVisible"
    dimensions          = { QueueName = var.sqs_queue_name }
    alarm_actions       = [aws_appautoscaling_policy.worker_scale_down.arn]
}