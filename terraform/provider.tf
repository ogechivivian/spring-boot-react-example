provider "aws" {
  region = var.region

  default_tags {
    tags = {
      project     = "eks_cluster"
      environment = "dev"
      managedby   = "terraform"
    }
  }
}