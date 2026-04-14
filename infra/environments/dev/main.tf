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
  # collect putputs from modules
  ecr_repo_url   = module.ecr.ecr_repo_url
  s3_bucket_name = module.s3.s3_bucket_name
  environment    = var.environment
  project        = var.project


  # pass these upon terraform apply
  image_uri      = var.image_uri
  model_key_name = var.model_key_name


}