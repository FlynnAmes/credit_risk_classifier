output "model_key_name" {

    description = "model artifact key name"
    value = aws_ssm_parameter.model_key_name.value
  
}


output "image_uri" {

    description = "uri of resource image"
    value = aws_ssm_parameter.image_uri.value
  
}

output "lambda_function_name" {

    description = "name of lambda function"
    value = aws_ssm_parameter.lambda_function_name.value
  
}