# uri for docker image in ECR (passed in as argument upon terraform apply)
resource "aws_ssm_parameter" "image_uri" {
  name  = "image-uri-${var.project}-${var.environment}"
  type  = "String"
  value = var.image_uri

}

# name of model artifact 'file' (passed in as argument upon terraform apply)
resource "aws_ssm_parameter" "model_key_name" {
  name  = "model-key-name-${var.project}-${var.environment}"
  type  = "String"
  value = var.model_key_name

}

# name of bucket containing model artifact
resource "aws_ssm_parameter" "model_bucket_name" {
  name  = "model-bucket-name-${var.project}-${var.environment}"
  type  = "String"
  value = var.s3_bucket_name

}

# name of the ecr repository
resource "aws_ssm_parameter" "ecr_repo_url" {
  name  = "ecr-repo-url-${var.project}-${var.environment}"
  type  = "String"
  value = var.ecr_repo_url
}

# name of the lambda function
resource "aws_ssm_parameter" "lambda_function_name" {
  name  = "lambda-function-name-${var.project}-${var.environment}"
  type  = "String"
  value = var.lambda_function_name
}

# name of the url for the API
resource "aws_ssm_parameter" "api_url" {
  name  = "api-url-${var.project}-${var.environment}"
  type  = "String"
  value = var.api_url
}