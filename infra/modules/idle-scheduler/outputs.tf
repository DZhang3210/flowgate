output "sleep_lambda_arn" {
    description = "sleep lambda arn"
    value = aws_lambda_function.sleep.arn
}

output "wake_lambda_arn" {
    description = "wake lambda arn"
    value = aws_lambda_function.wake.arn
}