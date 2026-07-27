output "sns_arn" {
  description = "arn for sns service"
  value = aws_sns_topic.alerts.arn
}

output "flow_logs_arn" {
    description = "ARN for flow logs"
    value = aws_cloudwatch_log_group.vpc_flow_logs.arn
}

output "alb_5xx_alarm_arn" {
  description = "ARN for the ALB 5xx rate alarm, used as an FIS stop condition"
  value = aws_cloudwatch_metric_alarm.alb_5xx_greater_than_1_percent.arn
}