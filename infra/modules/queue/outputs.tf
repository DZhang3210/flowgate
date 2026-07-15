output "sqs_queue_url" {
  description = "queue url"
  value = aws_sqs_queue.main.id
}

output "sqs_queue_arn" {
  description = "queue arn"
  value = aws_sqs_queue.main.arn
}

output "sqs_queue_name" {
  description = "queue name"
  value = aws_sqs_queue.main.name
}

output "dlq_name" {
  description = "dlq name"
  value = aws_sqs_queue.dlq.name
}

