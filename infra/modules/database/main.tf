resource "aws_db_instance" "main" {
  engine = "postgres"
  engine_version = "15"
  instance_class = var.instance_class
  db_name = "${var.app_name}_${var.environment}_rds"
  username = var.username
  password = var.password
  vpc_security_group_ids = var.vpc_sg_ids
  db_subnet_group_name = var.db_subnet_group_name
  multi_az = var.multi_az
  allocated_storage = var.storage_size
}