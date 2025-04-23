terraform {
  backend "s3" {
    bucket         = "eedb-015-2025-1-terraform-state"
    key            = "terraform/dev/terraform.tfstate"
    region         = "us-east-1"
    dynamodb_table = "terraform-locks"
    encrypt        = true
  }
}
