variable "app_name" {
    description = "Name of application"
    type = string
    default = "flowgate"
}

variable "environment"{
    description = "Env of application"
    type = string
    default = "staging"
}

variable "region"{
    description = "region of application"
    type = string
    default = "us-east-1"
}

variable "db_username" {
    description = "db username"
    type = string
    default = "username"
    sensitive = true
}

variable "db_password" {
    description = "db password"
    type = string
    default = "password"
    sensitive = true
}

variable "alert_email" {
  description = "alert email"
  type = string
  default = "alert_email"
  sensitive = true
}