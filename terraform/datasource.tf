data "aws_route53_zone" "domain" {
  name         = var.domain_name
  private_zone = false
}

data "aws_ami" "application_image" {

  most_recent      = true
  owners           = ["self"]

  filter {
    name   = "name"
    values = ["${var.project_name}-${var.project_environment}-*"]
  }

  filter {
    name   = "tag:Environment"
    values = [var.project_environment ]
  }

  filter {
    name   = "tag:Project"
    values = [ var.project_name]
  }

}

