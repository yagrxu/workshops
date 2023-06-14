locals {
  demo_cidr         = "10.1.1.0/24"
  imported_vpc_cidr = "10.1.0.0/16"
}

resource "aws_vpc" "demo" {
  cidr_block = local.imported_vpc_cidr
  tags = {
    Name = "imported VPC"
  }
}

resource "aws_subnet" "demo" {
  vpc_id     = aws_vpc.demo.id
  cidr_block = local.demo_cidr
  # availability_zone = "us-east-1a"
}
