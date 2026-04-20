terraform {
  backend "s3" {
    bucket         = "woolf-goit-tfstate-usw2-20260417"
    key            = "lesson-8-9/terraform.tfstate"
    region         = "us-west-2"
    dynamodb_table = "terraform-locks-usw2"
    encrypt        = true
  }
}
