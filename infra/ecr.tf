resource "aws_ecr_repository" "ecr_repo" {
  name = "credit-risk-classifier-tf"
  # force unique tags
  image_tag_mutability = "IMMUTABLE"

}