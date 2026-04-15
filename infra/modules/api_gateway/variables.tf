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

# limit to rate (num api calls per second)
variable "rate_limit" {
    type        = number 
  description = "limit to rate" 
  default = 5
}

# limit to burst (num concurrent requests)
variable "burst_limit" {
    type        = number 
  description = "limit to burst" 
  default = 5
}
