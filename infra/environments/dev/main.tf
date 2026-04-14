# specify region for all resources
provider "aws" {
  region = var.region
}

# define s3, ecr repo, lambda function, API gateway and 
module "s3" {
  source         = "../../modules"
  s3_bucket_name = var.s3_bucket_name
  ecr_repo_name = var.ecr_repo_name
}