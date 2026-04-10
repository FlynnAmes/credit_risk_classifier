# specify region for all resources
provider "aws" {
  region = "eu-west-2"
}

resource "aws_s3_bucket" "s3" {
  bucket = "credit-risk-classifier-tf"
}