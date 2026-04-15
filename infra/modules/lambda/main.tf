
# create role
resource "aws_iam_role" "lambda_role" {

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{

      Effect    = "Allow"
      Principal = { Service = "lambda.amazonaws.com" }
      Action    = "sts:AssumeRole"
    }]
  })

}


# assign policies for S3 read, and ability to log output to CLoudWatch
resource "aws_iam_role_policy_attachment" "lambda_role_attachment" {

  # create policy attachment for both policies that want to attach
  for_each = toset(["arn:aws:iam::aws:policy/AmazonS3ReadOnlyAccess",
  "arn:aws:iam::aws:policy/service-role/AWSLambdaBasicExecutionRole"])

  role       = aws_iam_role.lambda_role.name
  policy_arn = each.value
}


resource "aws_lambda_function" "lambda" {
  # need an IAM role to assign here also
  function_name = var.lambda_func_name
  role          = aws_iam_role.lambda_role.arn

  package_type = "Image"
  # Use SSM param to define image uri (so that can update in CI and terraform gets the changes)
  image_uri = var.ecr_image_uri
  # give 1Gb of memory
  memory_size = var.lambda_memory_limit
  timeout     = var.lambda_timeout_limit

  # set environment variable so knows to load from S3
  environment {
    variables = {
      # so that knows whether to run in local or cloud mode
      ENV = "aws"
      # so that can load in model from S3 (rather than hardcoding path)
      model_bucket_name = var.model_bucket_name
      model_key_name    = var.model_key_name
    }
  }

}