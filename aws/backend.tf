terraform {
  backend "s3" {
    bucket       = "tf-state-bucket-iac"
    key          = "xtichorg/iac/aws"
    region       = "us-east-1"
    use_lockfile = true
  }
}

