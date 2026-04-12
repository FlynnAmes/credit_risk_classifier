
# uri for docker image in ECR
resource "aws_ssm_parameter" "image_uri" {
  name  = "image_uri"
  type  = "String"
  value = "772928963391.dkr.ecr.eu-west-2.amazonaws.com/credit-risk-classifier-tf:latest"

  # so does not revert manual changes made by the CLI (so that can update docker image in CI)
  # note that is destroyed and redeployed, would need to manually update value above so not reset
  # to the initial image
  lifecycle {
    ignore_changes = [
      value,
    ]
  }
}

# name of model artifact 'file'
resource "aws_ssm_parameter" "model_key_name" {
  name  = "model_key_name"
  type  = "String"
  value = "standard.pkl"

  lifecycle {
    ignore_changes = [
      value,
    ]
  }
}

# all ssm parameter below here shouldn't be changed via CLI

# name of bucket containing model artifact
resource "aws_ssm_parameter" "model_bucket_name" {
  name  = "model_bucket_name"
  type  = "String"
  value = aws_s3_bucket.s3.bucket

}

# name of the ecr repository
resource "aws_ssm_parameter" "ecr_repo_url" {
  name  = "ecr_repo_url"
  type  = "String"
  value = aws_ecr_repository.ecr_repo.repository_url
}

# name of the lambda function
resource "aws_ssm_parameter" "lambda_function_name" {
  name  = "lambda_function_name"
  type  = "String"
  value = aws_lambda_function.lambda.function_name
}

# name of the url for the API
resource "aws_ssm_parameter" "api_url" {
  name  = "api_url"
  type  = "String"
  value = aws_apigatewayv2_api.api.api_endpoint
}