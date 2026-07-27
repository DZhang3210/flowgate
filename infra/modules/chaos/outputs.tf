output "kill_one_api_task_id" {
  description = "FIS experiment template ID for Experiment A"
  value       = aws_fis_experiment_template.kill_one_api_task.id
}

output "kill_all_api_tasks_id" {
  description = "FIS experiment template ID for Experiment B"
  value       = aws_fis_experiment_template.kill_all_api_tasks.id
}

output "disrupt_az_a_id" {
  description = "FIS experiment template ID for Experiment D (AZ-a)"
  value       = aws_fis_experiment_template.disrupt_az_a.id
}

output "disrupt_az_b_id" {
  description = "FIS experiment template ID for Experiment D (AZ-b)"
  value       = aws_fis_experiment_template.disrupt_az_b.id
}