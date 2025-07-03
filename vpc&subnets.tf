provider "aws" {
  region = "us-east-1"

}

resource "aws_vpc" "test-vpc" {
  cidr_block = "10.0.0.0/16"
}

resource "aws_subnet" "public-subnet" {
  vpc_id     = aws_vpc.test-vpc.id
  cidr_block = "10.0.0.0/24"

  tags = {
    Name = "Public-subnet"
  }
}


resource "aws_subnet" "private-subnet" {
  vpc_id     = aws_vpc.test-vpc.id
  cidr_block = "10.0.1.0/24"

  tags = {
    Name = "Private-subnet"
  }
}
resource "aws_security_group" "test_access" {
  name        = "test_access"
  vpc_id      = aws_vpc.test-vpc.id
  description = "allow ssh and http"

  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}



resource "aws_internet_gateway" "test-igw" {
  vpc_id = aws_vpc.test-vpc.id

  tags = {
    Name = "test-igw"
  }
}


resource "aws_route_table" "public-rt" {
  vpc_id = aws_vpc.test-vpc.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.test-igw.id
  }


  tags = {
    Name = "public-rt"
  }
}
resource "aws_route_table_association" "public-asso" {
  subnet_id      = aws_subnet.public-subnet.id
  route_table_id = aws_route_table.public-rt.id

}

resource "aws_instance" "sanjay-server" {
  ami             = "ami-05ffe3c48a9991133"
  subnet_id       = aws_subnet.public-subnet.id
  instance_type   = "t2.micro"
  security_groups = ["${aws_security_group.test_access.id}"]
  key_name        = "lti-key"
  tags = {
    Name     = "test-World"
    Stage    = "testing"
    Location = "chennai"
  }

}


resource "aws_eip" "sanjay-ec2-eip" {
  instance = aws_instance.sanjay-server.id
}


resource "aws_key_pair" "ltimind" {
  key_name   = "ltimind"
  public_key = "ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABgQCfrzWNVl7Eh97/W5VQ8oOtE3MNnK84D+Ix78lTHcP2Hk875Rqj9JXn+vgOT2ZySg7iifOnAi1pait1UoJ4yu053FspzCFuRVWRWdLPteU/9hzRmaHxuB3IJlMIRbiR0+NBFxwBjDcurY5oU3sCXuzDcJa4wBj+jp66nttPz/82X03REXyq04TK7vXeHqJWa9w67tkbV6TDvr+/o6rZGD4dPEi0hnWdBiEuHORa5u3Bluo04a/0iFoJ5aH7j8kLHRTYvxREP3Lg358oCijKUqo7a+JbgZi+t1kQVo3MnyM8xsuZN81h792c53w8zHMvpJv0YYpWsKW7tVbo5bMBJgRF6vsw7vOskyV+tWStyLQOT47FqnlDyPycnypCSapwuPlwsDoA0x3W0rwp8YVzcPLjHA85BEgVZ9AVBQtnLpJ8qDG3kAufyQYGItP54Oyf8uDWRjO1LXdqq9i5FKAtg8E+7chMQOgwTVxRjfcZaMpu2ZieLjok2me7Qe5sSc2+KDE= root@terr.example.com"
}

resource "aws_instance" "database-server" {
  ami             = "ami-05ffe3c48a9991133"
  subnet_id       = aws_subnet.private-subnet.id
  instance_type   = "t2.micro"
  security_groups = ["${aws_security_group.test_access.id}"]
  key_name        = "ltimind"
  tags = {
    Name     = "db-World"
    Stage    = "stage-base"
    Location = "delhi"
  }

}

resource "aws_eip" "nat-eip" {
  tags = {
    Name = "nat-eip"
  }
}

resource "aws_nat_gateway" "my-ngw" {
  allocation_id = aws_eip.nat-eip.id
  subnet_id     = aws_subnet.public-subnet.id
}

resource "aws_route_table" "private-rt" {
  vpc_id = aws_vpc.test-vpc.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_nat_gateway.my-ngw.id
  }
  tags = {
    Name = "private-rt"
  }
}

resource "aws_route_table_association" "private-asso" {
  subnet_id      = aws_subnet.private-subnet.id
  route_table_id = aws_route_table.private-rt.id
}
