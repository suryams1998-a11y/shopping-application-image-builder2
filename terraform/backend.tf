terraform {
  backend "s3" {
    bucket = "terraform1-backend-gayathris.shop"
    key    = "terraform.tfstate"
    region = "us-east-2"
  }
}


