
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
  function_name = "credit-risk-function-tf"
  role          = aws_iam_role.lambda_role.arn

  package_type = "Image"
  # hardcode the image uri and other params for now
  image_uri = "772928963391.dkr.ecr.eu-west-2.amazonaws.com/credit-risk-classifier-tf:latest"
  # give 1Gb of memory
  memory_size = 1024
  timeout     = 10
  
  # set environment variable so knows to load from S3
  environment {
    variables = {
        ENV = "aws"
    }
  }

}