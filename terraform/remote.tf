terraform {
  required_version = ">= 1.3.0"
  backend "s3" {
    bucket  = "ogechi-test-bucket"
    key     = "terraform.tfstate"
    region  = "us-east-1"
    encrypt = true
  }
}

