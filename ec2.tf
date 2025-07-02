provider "aws" {
  region     = "us-east-1"
  access_key = "access_key"
  secret_key = "secret_key"
}
 
 
resource "aws_instance" "web" {
  ami           = "ami-05ffe3c48a9991133"
  instance_type = "t2.micro"
 
  tags = {
    Name = "HelloWorld"
  }
}
