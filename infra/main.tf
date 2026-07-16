provider "aws" {
  region = var.region
}

module "networking" {
  source = "./modules/networking"
  vpc_flow_logs_iam_arn = module.security.vpc_flow_logs_iam_arn
  flow_logs_destination_arn = module.observability.flow_logs_arn
}

module "security" {
  source = "./modules/security"
  app_name    = var.app_name
  environment = var.environment
  vpc_id      = module.networking.vpc_id
  sqs_queue_arn = module.queue.sqs_queue_arn
  vpc_flow_logs_arn = module.observability.flow_logs_arn
  rds_arn = module.database.rds_arn
  ecs_cluster_name = module.compute.ecs_cluster_name
  aws_region = var.region
}

module "compute" {
  source = "./modules/compute"
  execution_role_arn = module.security.ecs_execution_iam_arn
  api_task_role_arn = module.security.ecs_api_iam_arn
  worker_task_role_arn = module.security.ecs_worker_iam_arn
  alb_security_group_id = module.security.alb_sg_id
  ecs_api_security_group_id = module.security.ecs_api_sg_id
  ecs_worker_security_group_id = module.security.ecs_worker_sg_id
  public_subnet_ids = module.networking.public_subnet_ids
  private_subnet_ids = module.networking.private_subnet_ids
  vpc_id = module.networking.vpc_id
  db_host = module.database.rds_address
  db_port = module.database.rds_port
  redis_host = module.cache.redis_address
  redis_port = module.cache.redis_port
  secret_manager_arn = module.security.aws_sm_arn
  sqs_queue_url = module.queue.sqs_queue_url
  sqs_queue_name = module.queue.sqs_queue_name
  image_tag = var.image_tag
}

module "database" {
  source = "./modules/database"
  username = var.db_username
  password = var.db_password
  db_subnet_group_name = module.networking.db_subnet_group_name
  vpc_sg_ids = [module.security.rds_sg_id]
}

module "cache" {
  source = "./modules/cache"
  security_group_ids = [module.security.redis_sg_id]
  subnet_group_name = module.networking.cache_subnet_group_name
}

module "queue"{
  source = "./modules/queue"
  app_name    = var.app_name
  environment = var.environment
}

module "observability" {
  source = "./modules/observability"
  alert_email = var.alert_email
  dlq_name = module.queue.dlq_name
  ecs_cluster_name = module.compute.ecs_cluster_name
  ecs_api_service_name = module.compute.ecs_api_service_name
  alb_arn_suffix = module.compute.alb_arn_suffix
  rds_identifier = module.database.rds_identifier
  cache_cluster_id = module.cache.cache_cluster_id
  sleep_lambda_arn = module.idle-scheduler.sleep_lambda_arn
}

module "idle-scheduler" {
  source = "./modules/idle-scheduler"
  app_name = var.app_name
  environment = var.environment
  lambda_role_arn = module.security.idle_scheduler_iam_arn
  ecs_cluster_name = module.compute.ecs_cluster_name
  ecs_api_service_name = module.compute.ecs_api_service_name
  ecs_worker_service_name = module.compute.ecs_worker_service_name
  rds_identifier = module.database.rds_identifier
  api_desired_count = module.compute.ecs_api_desired_count
  worker_desired_count = module.compute.ecs_worker_desired_count 
  sns_topic_arn = module.observability.sns_arn
}

module "cicd" {
  source = "./modules/cicd"
  app_name = var.app_name
  environment = var.environment
  api_ecr_arn = module.compute.api_ecr_arn
  worker_ecr_arn = module.compute.worker_ecr_arn
  api_ecs_arn = module.compute.api_ecs_arn
  worker_ecs_arn = module.compute.worker_ecs_arn
}