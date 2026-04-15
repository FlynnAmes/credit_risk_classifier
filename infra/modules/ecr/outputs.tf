# url for the ecr with docker image

output "ecr_repo_url" {

    description = "url of the ECR repository"
    value = aws_ecr_repository.ecr_repo.repository_url
  
}