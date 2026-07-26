output "kill_one_api_task_id" {
  description = "FIS experiment template ID for Experiment A"
  value       = aws_fis_experiment_template.kill_one_api_task.id
}

output "kill_all_api_tasks_id" {
  description = "FIS experiment template ID for Experiment B"
  value       = aws_fis_experiment_template.kill_all_api_tasks.id
}