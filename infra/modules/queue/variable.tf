variable "app_name" {
  description = "app name"
  type = string
  default = "flowgate"
}

variable "environment" {
    description = "app environment"
    type = string  
    default = "staging"
}

variable "max_receive_count" {
    description = "max sqs attempts before DLQ"
    type = number
    default = 3
}

variable "visibility_timeout_seconds" {
    description = "num seconds before retrying SQS packet"
    type = number
    default = 30
  
}