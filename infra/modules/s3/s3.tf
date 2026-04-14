# use variable to define bucket name
resource "aws_s3_bucket" "s3" {
    bucket = var.s3_bucket_name
  }