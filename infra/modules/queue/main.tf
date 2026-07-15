resource "aws_sqs_queue" "main" {
  name                       = "${var.app_name}-${var.environment}-sqs-queue"
  visibility_timeout_seconds = var.visibility_timeout_seconds

  redrive_policy = jsonencode({
    deadLetterTargetArn = aws_sqs_queue.dlq.arn
    maxReceiveCount     = var.max_receive_count
  })
}

resource "aws_sqs_queue" "dlq" {
  name                       = "${var.app_name}-${var.environment}-sqs-dlq"
}

