resource "aws_fis_experiment_template" "kill_one_api_task" {
  description = "Experiment A: stop one FlowGate API task, expect 0 user-facing errors"
  role_arn    = var.fis_role_arn

  stop_condition {
    source = "none"
  }

  target {
    name           = "api_task"
    resource_type  = "aws:ecs:task"
    selection_mode = "COUNT(1)"

    parameters = {
      cluster = var.ecs_cluster_name
      service = var.ecs_api_service_name
    }
  }

  action {
    name      = "stop_one_task"
    action_id = "aws:ecs:stop-task"

    target {
      key   = "Tasks"
      value = "api_task"
    }
  }

  tags = {
    Name = "${var.app_name}-${var.environment}-kill-one-api-task"
  }
}

resource "aws_fis_experiment_template" "kill_all_api_tasks" {
  description = "Experiment B: stop all FlowGate API tasks, expect 503s until ECS relaunches"
  role_arn    = var.fis_role_arn

  stop_condition {
    source = "none"
  }

  target {
    name           = "api_tasks"
    resource_type  = "aws:ecs:task"
    selection_mode = "ALL"

    parameters = {
      cluster = var.ecs_cluster_name
      service = var.ecs_api_service_name
    }
  }

  action {
    name      = "stop_all_tasks"
    action_id = "aws:ecs:stop-task"

    target {
      key   = "Tasks"
      value = "api_tasks"
    }
  }

  tags = {
    Name = "${var.app_name}-${var.environment}-kill-all-api-tasks"
  }
}