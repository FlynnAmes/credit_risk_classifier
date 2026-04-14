variable "region" {
  type        = string
  description = "Set a value for the default region"
  default     = "eu-west-2"
}

variable "s3_bucket_name" {
  type        = string
  description = "name of S3 bucket used to store model artifact"

}