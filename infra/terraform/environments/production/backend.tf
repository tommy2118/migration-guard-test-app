terraform {
  backend "s3" {
    bucket         = "migration-guard-test-app-terraform-state"
    key            = "production/terraform.tfstate"
    region         = "us-east-1"
    encrypt        = true
    dynamodb_table = "migration-guard-test-app-terraform-locks"
  }
}
