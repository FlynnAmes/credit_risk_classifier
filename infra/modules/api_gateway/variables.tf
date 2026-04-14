variable "api_gateway_name" {
  type        = string
  description = "name of api gateway"

}

variable "lambda_arn" {
  type        = string
  description = "ARN of lambda function (integration uri for the API)"
}

# name of the lambda function
variable "lambda_function_name" {
    type        = string
  description = "name of lambda function" 
}
