variable "lambda_func_name" {
  type        = string
  description = "name of lambda function"

}

variable "ecr_image_uri" {
  type        = string
  description = "uri of docker image on aws ECR"
}

variable "model_key_name" {
  type        = string
  description = "key name for model artifact on s3"
}

variable "model_bucket_name" {
  type        = string
  description = "name of bucket containing model artifact"
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
