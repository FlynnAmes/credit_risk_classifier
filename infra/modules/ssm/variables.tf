# to be defined when running terraform apply
variable "image_uri" {
    type = string
    description = "uri of docker image in ECR"
}

# to be defined when running terraform apply
variable "model_key_name" {
    type = string
    description = "key name of model artifact within the S3 bucket"
}

variable "s3_bucket_name" {
  type        = string
  description = "name of S3 bucket used to store model artifact"

}

# define ecr repo name
variable "ecr_repo_name" {
    type        = string
  description = "name of ecr repo for docker image"
  
}

# url of the ecr
variable "ecr_repo_url" {
    type        = string
  description = "name of ecr repo for docker image"
  
}


# name of the lambda function
variable "lambda_function_name" {
    type        = string
  description = "name of lambda function"
  
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