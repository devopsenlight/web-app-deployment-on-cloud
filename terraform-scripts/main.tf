terraform {
  backend "s3" {
    bucket         = "my-terraform-webapps-bucket"
    key            = "terraform.tfstate"
    region         = "ap-south-1"
    encrypt        = true
  }
}
