variable "aws_region" {
  type        = string
  description = "My AWS region name"
}

variable "project_name" {
  type        = string
  description = "My project name"
}

variable "project_environment" {
  type        = string
  description = "My project environment"
}


variable "instance_type" {
  type        = string
  description = "My instance type"
}

variable "webserver_ports" {
  type        = list(string)
  description = "My webserver security group ports"
}

variable "enable_public_ip" {
  type        = bool
  description = "Whether the public IP should be enabled"
}

variable "domain_name" {
  type        = string
  description = "My Route53 domain name"
}

variable "webserver_hostname" {
  type        = string
  description = "My webserver hostname"
}

