terraform {
  backend "s3" {
    bucket         = "flowgate-terraform-david"
    key            = "staging/terraform.tfstate"
    region         = "us-east-1"
    dynamodb_table = "flowgate-terraform-locks"
    encrypt        = true
  }
}