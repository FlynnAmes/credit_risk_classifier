# output bucket name for ssm

output "s3_bucket_name" {

    description = "name of s3 bucket containing model artifact"
    value = aws_s3_bucket.s3.bucket
  
}