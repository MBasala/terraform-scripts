terraform {
  backend "s3" {
    bucket = "my-terraform-state-bucket"
    key    = "path/to/my/key"
    region = "us-east-1"
  }
}

module "gerrit_services" {
  source = "./modules/gerrit_services"
}

module "aws_resources" {
  source = "./modules/aws_resources"
}
