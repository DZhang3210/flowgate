variable "app_name" {
    description = "app name"
    type = string
    default = "flowgate"
}

variable "environment"{
    description = "app env"
    type = string
    default = "staging"
}

variable "node_type" {
    description = "redis node type"
    type = string
    default = "cache.t3.micro"
}

variable "redis_version" {
    description = "redis version"
    type = string
    default = "7.1"
}

variable "security_group_ids" {
  description = "elasticache sg id"
  type = list(string)
}

variable "subnet_group_name" {
  description = "subnet group name"
  type = string
}
