output "sns_arn" {
  description = "arn for sns service"
  value = aws_sns_topic.alerts.arn
}

output "flow_logs_arn" {
    description = "ARN for flow logs"
    value = aws_cloudwatch_log_group.vpc_flow_logs.arn
}
