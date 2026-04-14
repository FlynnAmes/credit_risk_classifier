variable "region" {
  type        = string
  description = "Set a value for the default region"
  default     = "eu-west-2"
}


# variable "lambda_func_name" {
#   type        = string
#   description = "name of lambda function"

# }

# variable "api_gateway_name" {
#   type        = string
#   description = "name of api gateway"

# }

# to be defined when running terraform apply
variable "image_uri" {
  type        = string
  description = "uri of docker image in ECR"
}

# to be defined when running terraform apply
variable "model_key_name" {
  type        = string
  description = "key name of model artifact within the S3 bucket"
}

# name of environment that running in (e.g., devel, prod)
variable "environment" {
  type        = string
  description = "name of current environment for infra"

}

# name of project (for naming ecr repo etc)
variable "project" {
  type        = string
  description = "name of project"

}