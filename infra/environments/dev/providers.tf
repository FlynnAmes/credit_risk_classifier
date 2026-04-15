terraform {
  # keep terraform version flexible for now
  required_version = "~> 1.0"

  required_providers {

    aws = {

      source = "hashicorp/aws"
      # latest version at time of writing is 6.40
      version = "~> 6.40"
    }
  }
}