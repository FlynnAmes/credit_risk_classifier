# specify region for all resources
provider "aws" {
  region = var.region
}

# define s3 to store model artifact (note naming convention for resources using project and environment)
module "s3" {
  source         = "../../modules/s3"
  s3_bucket_name = "${var.project}-${var.environment}"
}

# repo to push docker image
module "ecr" {
  source        = "../../modules/ecr"
  ecr_repo_name = "${var.project}-${var.environment}"

}

# SSM parameters
module "ssm" {
  source         = "../../modules/ssm"
  ecr_repo_name  = "${var.project}-${var.environment}"
  s3_bucket_name = "${var.project}-${var.environment}"
  environment    = var.environment
  project        = var.project
  # pass these upon terraform apply
  image_uri      = ""
  model_key_name = ""

}