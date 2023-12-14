provider "aws" {
  region = "us-east-1"
}

resource "aws_instance" "ec2_instance" {
  ami           = "ami-0fc5d935ebf8bc3bc"
  count         = "1"
  instance_type = "t2.micro"
  key_name      = "vpc"
	
  tags = {
      Name = "EC2"
  }
} 
