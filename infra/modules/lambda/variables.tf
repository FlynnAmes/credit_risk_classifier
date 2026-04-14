variable "lambda_func_name" {
  type        = string
  description = "name of lambda function"

}

variable "lambda_memory_limit" {
  type        = string
  description = "memory limit for lambda function"
  default = 1024

}

variable "lambda_timeout_limit" {
  type        = string
  description = "timeout limit (secs) for lambda function"
  default = 20

}