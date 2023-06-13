
# https://registry.terraform.io/providers/hashicorp/aws/latest/docs
provider "aws" {
  region = var.region
}

resource "aws_vpc" "demo" {
  cidr_block = "10.0.0.0/16"
  # tags = {
  #   Name = "my first VPC by Terraform"
  # }
}

resource "aws_subnet" "public_subnet" {
  vpc_id     = aws_vpc.demo.id
  cidr_block = "10.0.1.0/24"
  # availability_zone = "us-east-1a"
}

resource "aws_subnet" "private_subnet" {
  vpc_id     = aws_vpc.demo.id
  cidr_block = "10.0.2.0/24"
  # availability_zone = "us-east-1b"
}


resource "aws_internet_gateway" "demo" {
  vpc_id = aws_vpc.demo.id
}

resource "aws_route_table" "demo" {
  vpc_id = aws_vpc.demo.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.demo.id
  }
}

resource "aws_route_table_association" "public_subnet_association" {
  subnet_id      = aws_subnet.private_subnet.id
  route_table_id = aws_route_table.demo.id
}

resource "aws_security_group" "demo" {
  name        = "demo"
  description = "demo"
  vpc_id      = aws_vpc.demo.id

  ingress {
    description = "ssh"
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
