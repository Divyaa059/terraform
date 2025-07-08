resource "aws_ami_from_instance" "my-images" {
  name               = "terim"
  source_instance_id = "i-031197f903dc9b37d"
  tags = {
    Name = "Hello-world"
  }
}
