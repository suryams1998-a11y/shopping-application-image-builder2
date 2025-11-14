#security group

resource "aws_security_group" "webserver" {
  name        = "${var.project_name}-${var.project_environment}-webserver"
  description = "${var.project_name}-${var.project_environment}-webserver"

  tags = {
    Name = "${var.project_name}-${var.project_environment}-webserver"
  }
}

#egress rule:

resource "aws_security_group_rule" "webserver_egress" {
  type              = "egress"
  security_group_id = aws_security_group.webserver.id
  from_port         = 0
  to_port           = 0
  protocol          = "-1"
  cidr_blocks       = ["0.0.0.0/0"]
  ipv6_cidr_blocks  = ["::/0"]
}

#ingress rule

resource "aws_security_group_rule" "webserver_ingress" {
  for_each          = toset(var.webserver_ports)
  type              = "ingress"
  security_group_id = aws_security_group.webserver.id
  from_port         = each.value
  to_port           = each.value
  protocol          = "tcp"
  cidr_blocks       = ["0.0.0.0/0"]
  ipv6_cidr_blocks  = ["::/0"]
}



#webserver instance
resource "aws_instance" "webserver" {

  ami                    = data.aws_ami.application_image.image_id
  instance_type          = var.instance_type
  key_name               = "key-ohio"
  vpc_security_group_ids = [aws_security_group.webserver.id]

  tags = {
    Name = "webserver-${var.project_name}-${var.project_environment}"
  }

  lifecycle {
    create_before_destroy = true
  }
}

# Elastic IP
resource "aws_eip" "webserver" {
  count = var.enable_public_ip ? 1 : 0

  tags = {
    Name = "webserver-${var.project_name}-${var.project_environment}-eip"
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
  count   = var.enable_public_ip ? 1 : 0
  zone_id = data.aws_route53_zone.domain.zone_id
  name    = "${var.webserver_hostname}.${var.domain_name}"
  type    = "A"
  ttl     = 5
  records = [aws_eip.webserver[0].public_ip]
}


# Route53 Record (EIP disabled)
resource "aws_route53_record" "webserver_eip_disabled" {
  count   = var.enable_public_ip ? 0 : 1
  zone_id = data.aws_route53_zone.domain.zone_id
  name    = "${var.webserver_hostname}.${var.domain_name}"
  type    = "A"
  ttl     = 5
  records = [aws_instance.webserver.public_ip]
}

