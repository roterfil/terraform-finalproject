terraform {
  backend "s3" {
    bucket       = "borromeo-tf-state-bucket"
    key          = "final-project/terraform.tfstate"
    region       = "ap-southeast-1"
    encrypt      = true
    use_lockfile = true
  }
}