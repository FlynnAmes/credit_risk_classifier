# name of lambda function

output "lambda_function_name" {

    description = "name of lambda function"
    value = aws_lambda_function.lambda.function_name
  
}