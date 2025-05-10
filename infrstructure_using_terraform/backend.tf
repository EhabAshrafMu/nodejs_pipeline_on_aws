terraform {
  backend "s3" {
    bucket       = "terraform-test-ehab"
    key          = "iti-lab/terrafrom.tfstate"
    region       = "eu-north-1"
    encrypt      = true
    use_lockfile = true
  }
}
