
# uri for docker image in ECR
resource "aws_ssm_parameter" "image_uri" {
  name  = "image_uri"
  type  = "String"
  value = "772928963391.dkr.ecr.eu-west-2.amazonaws.com/credit-risk-classifier-tf:latest"

  # so does not revert manual changes made by the CLI (so that can update docker image in CI)
  # note that is destroyed and redeployed, would need to manually update value above so not reset
  # to the initial image
  lifecycle {
    ignore_changes = [
      value,
    ]
  }
}

# name of bucket containing model artifact
resource "aws_ssm_parameter" "model_bucket_name" {
  name  = "model_bucket_name"
  type  = "String"
  value = aws_s3_bucket.s3.bucket

  lifecycle {
    ignore_changes = [
      value,
    ]
  }
}

# name of model artifact 'file'
resource "aws_ssm_parameter" "model_key_name" {
  name  = "model_key_name"
  type  = "String"
  value = "standard.pkl"

  lifecycle {
    ignore_changes = [
      value,
    ]
  }
}