data "archive_file" "sleep_lambda_zip" {
    type = "zip"
    source_file = "${path.module}/lambda/sleep.py"
    output_path = "${path.module}/lambda/sleep.zip"
}

data "archive_file" "wake_lambda_zip" {
    type = "zip"
    source_file = "${path.module}/lambda/wake.py"
    output_path = "${path.module}/lambda/wake.zip"
}

resource "aws_lambda_function" "sleep" {
    function_name = "${var.app_name}-${var.environment}-sleep"
    filename = data.archive_file.sleep_lambda_zip.output_path
    source_code_hash = data.archive_file.sleep_lambda_zip.output_base64sha256
    handler = "sleep.lambda_handler"
    runtime = "python3.12"
    role = var.lambda_role_arn
    timeout = 300

    environment {
        variables = {
            ECS_CLUSTER = var.ecs_cluster_name
            ECS_API_SERVICE = var.ecs_api_service_name
            ECS_WORKER_SERVICE = var.ecs_worker_service_name
            RDS_IDENTIFIER = var.rds_identifier
        }
    }
}

resource "aws_lambda_function" "wake" {
    function_name = "${var.app_name}-${var.environment}-wake"
    filename = data.archive_file.wake_lambda_zip.output_path
    source_code_hash = data.archive_file.wake_lambda_zip.output_base64sha256
    handler = "wake.lambda_handler"
    runtime = "python3.12"
    role = var.lambda_role_arn
    timeout = 800

    environment {
        variables = {
            ECS_CLUSTER = var.ecs_cluster_name
            ECS_API_SERVICE = var.ecs_api_service_name
            ECS_WORKER_SERVICE = var.ecs_worker_service_name
            RDS_IDENTIFIER = var.rds_identifier
            API_DESIRED_COUNT =var.api_desired_count
            WORKER_DESIRED_COUNT =var.worker_desired_count
        }
    }
}

resource "aws_lambda_permission" "allow_sns_invoke" {
  statement_id  = "AllowSNSInvoke"
  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.sleep.function_name
  principal     = "sns.amazonaws.com"
  source_arn    = var.sns_topic_arn
}