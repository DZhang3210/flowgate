variable "app_name" {
  description = "app name"
  type = string
  default = "flowgate"
}

variable "environment" {
  description = "current app env"
  type = string
  default = "staging"
}

variable "multi_az" {
  description = "should it have multiple AZs"
  type = bool
  default = false
}

variable "username" {
  description = "database username"
  type = string
  sensitive = true
}

variable "password" {
    description = "database password"
    type = string
    sensitive = true
}

variable "db_subnet_group_name" {
    description = "db subnet group name"
    type = string
}

variable "vpc_sg_ids" {
    description = "list of sg ids"
    type = list(string) 
}

variable "storage_size" {
  description = "db storage size"
  type = number
  default = 256
}

variable "instance_class"{
    description = "database instance"
    type = string
    default = "db.t3.micro"
}
