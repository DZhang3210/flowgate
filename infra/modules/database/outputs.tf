output "rds_address" {
  description = "address for rds instance"
  value = aws_db_instance.main.address
}

output "rds_port" {
  description = "port for rds instance"
  value = aws_db_instance.main.port
}

output "rds_arn"{
  description = "arn for rds instance"
  value = aws_db_instance.main.arn
}

output "rds_identifier" {
  description = "rds identifier"
  value = aws_db_instance.main.identifier
}