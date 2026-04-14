# specify region for all resources
provider "aws" {
  region = var.region
}

# get s3 bucket module
module "s3" {
  source         = "../../modules"
  s3_bucket_name = var.s3_bucket_name
}