resource "aws_sns_topic" "alerts" {
  name = "${var.app_name}-${var.environment}-alerts"
}

resource "aws_sns_topic_subscription" "alert_email" {
  topic_arn = aws_sns_topic.alerts.arn
  protocol = "email"
  endpoint = var.alert_email
}

resource "aws_sns_topic_subscription" "alert_lambda" {
  topic_arn = aws_sns_topic.alerts.arn
  protocol = "lambda"
  endpoint = var.sleep_lambda_arn
}


resource "aws_cloudwatch_log_group" "vpc_flow_logs"{
    name = "/aws/vpc-flow-logs/${var.app_name}-${var.environment}"
}

resource "aws_cloudwatch_metric_alarm" "dlq_greater_than_zero" {
    alarm_name          = "${var.app_name}-dlq-greater-than-zero"
    namespace           = "AWS/SQS"
    comparison_operator = "GreaterThanOrEqualToThreshold"
    threshold           = 1
    evaluation_periods  = 1
    period              = 60
    statistic           = "Maximum"
    metric_name         = "ApproximateNumberOfMessagesVisible"
    dimensions          = { QueueName = var.dlq_name }
    alarm_actions       = [aws_sns_topic.alerts.arn]
}


resource "aws_cloudwatch_metric_alarm" "ecs_api_cpu_greater_than_eighty" {
    alarm_name          = "${var.app_name}-ecs-api-cpu-greater-than-eighty"
    namespace           = "AWS/ECS"
    comparison_operator = "GreaterThanThreshold"
    threshold           = 80
    evaluation_periods  = 3
    period              = 60
    statistic           = "Average"
    metric_name         = "CPUUtilization"
    dimensions          = { ClusterName = var.ecs_cluster_name, ServiceName = var.ecs_api_service_name }
    alarm_actions       = [aws_sns_topic.alerts.arn]
}

resource "aws_cloudwatch_metric_alarm" "ecs_api_memory_greater_than_eighty" {
    alarm_name          = "${var.app_name}-ecs-api-memory-greater-than-eighty"
    namespace           = "AWS/ECS"
    comparison_operator = "GreaterThanThreshold"
    threshold           = 80
    evaluation_periods  = 3
    period              = 60
    statistic           = "Average"
    metric_name         = "MemoryUtilization"
    dimensions          = { ClusterName = var.ecs_cluster_name, ServiceName = var.ecs_api_service_name }
    alarm_actions       = [aws_sns_topic.alerts.arn]
}

resource "aws_cloudwatch_metric_alarm" "alb_5xx_greater_than_1_percent" {
    alarm_name          = "${var.app_name}-alb-5xx-greater-than-1-percent"
    comparison_operator = "GreaterThanThreshold"
    threshold           = 1
    evaluation_periods  = 3
    alarm_actions       = [aws_sns_topic.alerts.arn]

    metric_query {
      id = "m1"
      metric {
        metric_name = "HTTPCode_Target_5XX_Count"
        namespace   = "AWS/ApplicationELB"
        period      = 60
        stat        = "Sum"
        dimensions  = { LoadBalancer = var.alb_arn_suffix }
      }
    }
    metric_query {
      id = "m2"
      metric {
        metric_name = "RequestCount"
        namespace   = "AWS/ApplicationELB"
        period      = 60
        stat        = "Sum"
        dimensions  = { LoadBalancer = var.alb_arn_suffix }
      }
    }

    metric_query {
      id          = "e1"
      expression  = "(m1/m2)*100"
      label       = "5xx Error Rate"
      return_data = true
    }    
}

resource "aws_cloudwatch_metric_alarm" "alb_p99_greater_than_500" {
    alarm_name          = "${var.app_name}-alb-p99-greater-than-500"
    namespace           = "AWS/ApplicationELB"
    comparison_operator = "GreaterThanThreshold"
    threshold           = 0.5
    evaluation_periods  = 3
    period              = 60
    extended_statistic  = "p99"
    metric_name         = "TargetResponseTime"
    dimensions  = { LoadBalancer = var.alb_arn_suffix }
    alarm_actions       = [aws_sns_topic.alerts.arn]
}

resource "aws_cloudwatch_metric_alarm" "alb_no_requests_for_1_hour" {
    alarm_name          = "${var.app_name}-alb-no-requests-for-1-hour"
    namespace           = "AWS/ApplicationELB"
    comparison_operator = "LessThanOrEqualToThreshold"
    threshold           = 0
    treat_missing_data = "breaching"
    evaluation_periods  = 10
    datapoints_to_alarm = 7
    period              = 6 * 60
    statistic           = "Sum"
    metric_name         = "RequestCount"
    dimensions  = { LoadBalancer = var.alb_arn_suffix }
    alarm_actions       = [aws_sns_topic.alerts.arn]
}

resource "aws_cloudwatch_metric_alarm" "rds_cpu_greater_than_70" {
    alarm_name          = "${var.app_name}-rds-cpu-greater-than-70"
    namespace           = "AWS/RDS"
    comparison_operator = "GreaterThanThreshold"
    threshold           = 70
    evaluation_periods  = 3
    period              = 60
    statistic           = "Average"
    metric_name         = "CPUUtilization"
    dimensions  = { DBInstanceIdentifier = var.rds_identifier }
    alarm_actions       = [aws_sns_topic.alerts.arn]
}

resource "aws_cloudwatch_metric_alarm" "rds_storage_less_than_5_gb" {
    alarm_name          = "${var.app_name}-rds-storage-less-than-5-gb"
    namespace           = "AWS/RDS"
    comparison_operator = "LessThanThreshold"
    threshold           = 5 * (1024 * 1024 * 1024)
    evaluation_periods  = 3
    period              = 60
    statistic           = "Minimum"
    metric_name         = "FreeStorageSpace"
    dimensions  = { DBInstanceIdentifier = var.rds_identifier }
    alarm_actions       = [aws_sns_topic.alerts.arn]
}

resource "aws_cloudwatch_metric_alarm" "redis_cpu_greater_than_70" {
    alarm_name          = "${var.app_name}-redis-cpu-greater-than-70"
    namespace           = "AWS/ElastiCache"
    comparison_operator = "GreaterThanThreshold"
    threshold           = 70
    evaluation_periods  = 3
    period              = 60
    statistic           = "Average"
    metric_name         = "EngineCPUUtilization"
    dimensions  = { CacheClusterId = var.cache_cluster_id }
    alarm_actions       = [aws_sns_topic.alerts.arn]
}

resource "aws_cloudwatch_metric_alarm" "redis_hit_rate_less_than_80_percent" {
    alarm_name          = "${var.app_name}-redis-hit-rate-less-than-80-percent"
    comparison_operator = "LessThanThreshold"
    threshold           = 80
    evaluation_periods  = 3
    alarm_actions       = [aws_sns_topic.alerts.arn]

    metric_query {
      id = "m1"
      metric {
        metric_name = "CacheHits"
        namespace   = "AWS/ElastiCache"
        period      = 60
        stat        = "Sum"
        dimensions  = { CacheClusterId = var.cache_cluster_id }
      }
    }
    metric_query {
      id = "m2"
      metric {
        metric_name = "CacheMisses"
        namespace   = "AWS/ElastiCache"
        period      = 60
        stat        = "Sum"
        dimensions  = { CacheClusterId = var.cache_cluster_id }
      }
    }

    metric_query {
      id          = "e1"
      expression  = "(m1/(m1+m2))*100"
      label       = "Cache Hit Ratio"
      return_data = true
    }    
}



resource "aws_cloudwatch_dashboard" "main" {
  dashboard_name = "${var.app_name}-${var.environment}"
  dashboard_body = jsonencode({
    widgets = [
      {
        type = "metric"
        x = 0
        y = 0
        width = 12
        height = 6
        properties = {
          metrics = [
            ["AWS/ApplicationELB", "RequestCount", "LoadBalancer", var.alb_arn_suffix]
          ]
          period = 300
          stat = "Sum"
          region = "us-east-1"
          title = "ALB Requests"
        }
      },
      {
        type = "metric"
        x = 0 
        y = 12
        width = 12
        height = 12
        properties = {
          metrics = [
            ["AWS/ECS", "CPUUtilization", "ClusterName", var.ecs_cluster_name,"ServiceName",var.ecs_api_service_name]
          ]
          period = 300
          stat = "Average"
          region = "us-east-1"
          title = "ECS API CPU"
        }
      },
      {
        type = "metric"
        x = 12
        y = 12
        width = 12
        height = 12
        properties = {
          metrics = [
            ["AWS/ECS", "MemoryUtilization", "ClusterName", var.ecs_cluster_name,"ServiceName",var.ecs_api_service_name]
          ]
          period = 300
          stat = "Average"
          region = "us-east-1"
          title = "ECS API Memory"
        }
      },
      {
        type = "metric"
        x = 0
        y = 24
        width = 12
        height = 12
        properties = {
          metrics = [
            ["AWS/ElastiCache", "CacheHits", "CacheClusterId", var.cache_cluster_id, { id = "m1", visible = false }],
            ["AWS/ElastiCache", "CacheMisses", "CacheClusterId", var.cache_cluster_id, { id = "m2", visible = false }],
            [{ expression = "(m1/(m1+m2))*100", label = "Cache Hit Ratio", id = "e1" }]
          ]
          period = 300
          stat = "Sum"
          region = "us-east-1"
          title = "Elasticache Hit Rate"
        }
      },
      {
        type = "metric"
        x = 12
        y = 24
        width = 12
        height = 12
        properties = {
          annotations = {
            horizontal = [
              {label = "Alarm Threshold", value = 1}
            ]
          }
          metrics = [
            ["AWS/SQS", "ApproximateNumberOfMessagesVisible", "QueueName", var.dlq_name]
          ]
          period = 300
          stat = "Maximum"
          region = "us-east-1"
          title = "DLQ Approximate Number of Messages"
        }
      },
      {
        type = "alarm"
        x = 0
        y = 36
        width = 24
        height = 6
        properties = {
          title = "Alarm Status"
          alarms = [
            aws_cloudwatch_metric_alarm.dlq_greater_than_zero.arn,
            aws_cloudwatch_metric_alarm.ecs_api_cpu_greater_than_eighty.arn,
            aws_cloudwatch_metric_alarm.ecs_api_memory_greater_than_eighty.arn,
            aws_cloudwatch_metric_alarm.alb_5xx_greater_than_1_percent.arn,
            aws_cloudwatch_metric_alarm.alb_p99_greater_than_500.arn,
            aws_cloudwatch_metric_alarm.rds_cpu_greater_than_70.arn,
            aws_cloudwatch_metric_alarm.rds_storage_less_than_5_gb.arn,
            aws_cloudwatch_metric_alarm.redis_cpu_greater_than_70.arn,
            aws_cloudwatch_metric_alarm.redis_hit_rate_less_than_80_percent.arn,
          ]
          region = "us-east-1"
        }
      },
      {
        type = "metric"
        x = 0
        y = 42
        width = 12
        height = 12
        properties = {
          metrics = [
            [{ expression = "SEARCH('{flowgate,TenantId} MetricName=\"RateLimitHits\"', 'Sum', 300)", label = "RateLimitHits (all tenants)", id = "e1" }]
          ]
          period = 300
          stat = "Average"
          region = "us-east-1"
          title = "Number of Rate Limit Hits"
        }
      },
    ]
  })
}


