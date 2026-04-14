variable "region" {
  type        = string
  description = "Set a value for the default region"
  default     = "eu-west-2"
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

##############
# to be defined when running terraform apply
variable "image_uri" {
  type        = string
  description = "uri of docker image in ECR"
}

variable "model_key_name" {
  type        = string
  description = "key name of model artifact within the S3 bucket"
}