resource "aws_security_group" "web_access23" {
  name        = "web_access23"
  description = "Allow traffic"

  tags = {
    Name = "web_access23"
  }
}

resource "aws_vpc_security_group_ingress_rule" "allow_http" {
  security_group_id = aws_security_group.web_access23.id
  cidr_ipv4         = "0.0.0.0/0"
  from_port         = 80
  ip_protocol       = "tcp"
  to_port           = 80
}

resource "aws_vpc_security_group_ingress_rule" "allow_ssh" {
  security_group_id = aws_security_group.web_access23.id
  cidr_ipv4         = "0.0.0.0/0"
  from_port         = 22
  ip_protocol       = "tcp"
  to_port           = 22
}

resource "aws_vpc_security_group_ingress_rule" "allow_https" {
  security_group_id = aws_security_group.web_access23.id
  cidr_ipv4         = "0.0.0.0/0"
  from_port         = 443
  ip_protocol       = "tcp"
  to_port           = 443
}
resource "aws_vpc_security_group_egress_rule" "allow_all_taraffic" {
  security_group_id = aws_security_group.web_access23.id
  cidr_ipv4         = "0.0.0.0/0"
  ip_protocol       = "-1"
}

#ec2 instance code starts here
resource "aws_instance" "custom-server" {
  ami               = "ami-05ffe3c48a9991133"
  availability_zone = "us-east-1a"
  instance_type     = "t2.micro"
  security_groups   = ["${aws_security_group.web_access23.name}"]
  key_name          = "lti-mahape-key"


  user_data = <<-EOF
        #!/bin/bash
        sudo yum install httpd -y
        sudo systemctl start httpd
        sudo systemctl enable httpd
        echo "<h1>custom  webserver using terraform</h1>" | sudo tee /var/www/html/index.html
  EOF
  tags = {
    Name     = "hello-India"
    Stage    = "testing"
    Location = "India"
  }
}
