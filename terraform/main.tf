# keyPair Creation
resource "aws_key_pair" "authentication_key" {
  key_name   = "${var.project_name}-${var.project_environment}"
  public_key = file("mykey.pub")
  tags = {
    "Name"        = "${var.project_name}-${var.project_environment}"
  }
}

# Creating  SecurityGroup For Webserver
resource "aws_security_group" "webserver" {

  name        = "${var.project_name}-${var.project_environment}-webserver"
  description = "${var.project_name}-${var.project_environment}-webserver"

  tags = {
    Name = "${var.project_name}-${var.project_environment}-webserver"
  }
}


resource "aws_security_group_rule" "webserver_http" {
  type              = "ingress"
  security_group_id = aws_security_group.webserver.id
  from_port         = 80
  to_port           = 80
  protocol          = "tcp"
  cidr_blocks       = ["0.0.0.0/0"]
  ipv6_cidr_blocks  = ["::/0"]
  
}

resource "aws_security_group_rule" "webserver_https" {
  type              = "ingress"
  security_group_id = aws_security_group.webserver.id
  from_port         = 443
  to_port           = 443
  protocol          = "tcp"
  cidr_blocks       = ["0.0.0.0/0"]
  ipv6_cidr_blocks  = ["::/0"]
  
}

resource "aws_security_group_rule" "webserver_ssh" {
  type              = "ingress"
  security_group_id = aws_security_group.webserver.id
  from_port         = 22
  to_port           = 22
  protocol          = "tcp"
  cidr_blocks       = ["0.0.0.0/0"]
  ipv6_cidr_blocks  = ["::/0"]
}

resource "aws_security_group_rule" "webserver_egress" {
  type              = "egress"
  security_group_id = aws_security_group.webserver.id
  from_port         = 0
  to_port           = 0
  protocol          = "-1"
  cidr_blocks       = ["0.0.0.0/0"]
  ipv6_cidr_blocks  = ["::/0"]
  
}


# Creating Webserver Instance
resource "aws_instance" "webserver" {

  ami                    = var.ami_id
  instance_type          = var.instance_type
  key_name               = "key-ohio"
  vpc_security_group_ids = [ aws_security_group.webserver.id  ]
  user_data              = file("setup.sh")
  tags = {
    "Name"        = "webserver-${var.project_name}-${var.project_environment}"
  }
}



# Elastic IP
resource "aws_eip" "webserver" {
  count = var.enable_public_ip ? 1 : 0
  tags = {
    Name = "webserver-${var.project_name}-${var.project_environment}-eip"
  }


  
  lifecycle {
    create_before_destroy = true
  }
}

# EIP Association
resource "aws_eip_association" "webserver" {
  count         = var.enable_public_ip ? 1 : 0
  instance_id   = aws_instance.webserver.id
  allocation_id = aws_eip.webserver[0].id
}

# Route53 Record (EIP enabled)
resource "aws_route53_record" "webserver_eip_enabled" {
  count   = var.enable_public_ip == true ? 1 : 0
  zone_id = data.aws_route53_zone.domain.zone_id
  name    = "${var.webserver_hostname}.${var.domain_name}"
  type    = "A"
  ttl     = 5
  records = [aws_eip.webserver[0].public_ip]
}

# Route53 Record (EIP disabled)
resource "aws_route53_record" "webserver_eip_disabled" {
  count   = var.enable_public_ip == false ? 1 : 0
  zone_id = data.aws_route53_zone.domain.zone_id
  name    = "${var.webserver_hostname}.${var.domain_name}"
  type    = "A"
  ttl     = 5
  records = [aws_instance.webserver.public_ip]
}

