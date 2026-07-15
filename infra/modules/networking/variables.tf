variable "name_prefix"{
  description = "Prefix applied to all resource names"
  type = string
  default = "flowgate-staging"
}

variable "nat_gateway_count" {
  description = "Number of Nat Gateways (1 for staging. 2 for prod)"
  type = number
  default = 1
}

variable "azs" {
  description = "List of availability zones"
  type = list(string)
  default = ["us-east-1a", "us-east-1b"]
}

variable "tags" {
  description = "Tags applied to all Reousrces"
  type = map(string)
  default = {}
}

variable "vpc_cidr" {
  description = "CIDR for vpc"
  type = string
  default = "10.0.0.0/16"
}

variable "public_subnet_cidrs" {
  description = "CIDRs for public subnet"
  type = list(string)
  default = ["10.0.0.0/24", "10.0.1.0/24"]
}

variable "private_subnet_cidrs" {
  description = "CIDR for private subnet"
  type = list(string)
  default = ["10.0.10.0/24", "10.0.11.0/24"]
}

variable "database_subnet_cidrs" {
  description = "CIDR for database subnet"
  type = list(string)
  default = ["10.0.20.0/24", "10.0.21.0/24"]
}

variable "vpc_flow_logs_iam_arn" {
  description = "ARN for VPC flow logs"
  type = string
}

variable "flow_logs_destination_arn" {
  description = "ARN for flow logs"
  type = string
}