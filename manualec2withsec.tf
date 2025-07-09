provider "aws" {
  region     = "us-east-1"
  access_key = ".........."
  secret_key = "XXXXXXXXXXXXXXXXx"
}

resource "aws_instance" "web" {
  ami                    = "ami-05ffe3c48a9991133"
  instance_type          = "t2.micro"
  key_name               = "lti-mahape-key"
  availability_zone           = "us-east-1a"
  vpc_security_group_ids = [aws_security_group.allow_tls.id]
  tags = {
    Name = "new_instance"
  }
}

resource "aws_security_group" "allow_tls" {
  name        = "allow_tls"
  description = "Allow TLS inbound traffic and all outbound traffic"

  tags = {
    Name = "allow_tls"
  }
}

resource "aws_vpc_security_group_ingress_rule" "allow_ipv4" {
  security_group_id = aws_security_group.allow_tls.id
  cidr_ipv4         = "0.0.0.0/0"
  from_port         = 443
  ip_protocol       = "tcp"
  to_port           = 443
}
resource "aws_vpc_security_group_ingress_rule" "allow_http" {
  security_group_id = aws_security_group.allow_tls.id
  cidr_ipv4         = "0.0.0.0/0"
  from_port         = 80
  ip_protocol       = "tcp"
  to_port           = 80
}

resource "aws_vpc_security_group_egress_rule" "allow_all_traffic_ipv4" {
  security_group_id = aws_security_group.allow_tls.id
  cidr_ipv4         = "0.0.0.0/0"
  ip_protocol       = "-1"
}
