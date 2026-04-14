# name of lambda function

output "lambda_function_name" {

    description = "name of lambda function"
    value = aws_lambda_function.lambda.function_name
  
}

# ARN of lambda function

output "lambda_arn" {

    description = "ARN of lambda function (for integration uri for API)"
    value = aws_lambda_function.lambda.invoke_arn
  
}