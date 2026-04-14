terraform {

  # set place where going store the state file
  backend "s3" {
    # use manually set up bucket for now
    bucket = "terraform-state-dev-772928963391"
    key    = "terraform.tfstate"
    region = "eu-west-2"

    # lock file for locking the terraform state
    use_lockfile = true
  }

}