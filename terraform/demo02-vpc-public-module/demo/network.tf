
resource "aws_ec2_transit_gateway" "demo" {
  description = "demo"
}

resource "aws_ec2_transit_gateway_vpc_attachment" "vpc_module_public_subnets_attachment" {
  subnet_ids         = module.vpc.public_subnets
  transit_gateway_id = aws_ec2_transit_gateway.demo.id
  vpc_id             = module.vpc.vpc_id
}

resource "aws_ec2_transit_gateway_vpc_attachment" "vpc_imported_subnets_attachment" {
  subnet_ids         = [aws_subnet.demo.id]
  transit_gateway_id = aws_ec2_transit_gateway.demo.id
  vpc_id             = aws_vpc.demo.id
}

data "aws_route_tables" "public_module_route_tables" {
  vpc_id = module.vpc.vpc_id

  # filter {
  #   name   = "tag:kubernetes.io/kops/role"
  #   values = ["private*"]
  # }
}

data "aws_route_table" "imported_vpc_route_table" {
  vpc_id = aws_vpc.demo.id
}

resource "aws_route" "public_module_vpc_route" {
  count                  = length(data.aws_route_tables.public_module_route_tables.ids)
  route_table_id         = tolist(data.aws_route_tables.public_module_route_tables.ids)[count.index]
  destination_cidr_block = local.imported_vpc_cidr
  transit_gateway_id     = aws_ec2_transit_gateway.demo.id
}

resource "aws_route" "imported_vpc_route" {
  count                  = length(module.vpc.private_subnets_cidr_blocks)
  route_table_id         = data.aws_route_table.imported_vpc_route_table.id
  destination_cidr_block = local.vpc_cidr
  transit_gateway_id     = aws_ec2_transit_gateway.demo.id
}
