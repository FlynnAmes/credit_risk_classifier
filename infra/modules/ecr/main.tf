resource "aws_ecr_repository" "ecr_repo" {
  name = var.ecr_repo_name
  # force unique tags
  image_tag_mutability = "IMMUTABLE"

}