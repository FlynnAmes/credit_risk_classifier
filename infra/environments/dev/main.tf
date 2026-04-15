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

# lambda function
module "lambda" {
  source            = "../../modules/lambda"
  lambda_func_name  = "${var.project}-${var.environment}"
  model_bucket_name = module.s3.s3_bucket_name
  # artifacts tracked by SSM (and updated during CI)
  model_key_name = module.ssm.model_key_name
  ecr_image_uri  = module.ssm.image_uri
}


# SSM parameters
module "ssm" {
  source         = "../../modules/ssm"
  environment    = var.environment
  project        = var.project
  ecr_repo_name  = "${var.project}-${var.environment}"
  image_uri      = var.image_uri
  model_key_name = var.model_key_name

  # collect outputs from modules
  ecr_repo_url         = module.ecr.ecr_repo_url
  s3_bucket_name       = module.s3.s3_bucket_name
  lambda_function_name = module.lambda.lambda_function_name
  api_url              = module.api_gateway.api_url
}

module "api_gateway" {
  source               = "../../modules/api_gateway"
  api_gateway_name     = "${var.project}-${var.environment}"
  lambda_arn           = module.lambda.lambda_arn
  lambda_function_name = module.lambda.lambda_function_name
}
