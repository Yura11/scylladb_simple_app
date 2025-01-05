resource "aws_vpc" "main" {
  cidr_block           = var.vpc_cidr
  enable_dns_support   = true
  enable_dns_hostnames = true

  tags = merge(
    {
      Name = "${var.project_name}-vpc"
    },
    var.tags
  )
}

resource "aws_subnet" "public" {
  count = length(var.public_subnets)

  cidr_block = var.public_subnets[count.index]
  vpc_id     = aws_vpc.main.id
  map_public_ip_on_launch = true

  tags = merge(
    {
      Name = "${var.project_name}-public-subnet-${count.index}"
    },
    var.tags
  )
}

resource "aws_internet_gateway" "main" {
  vpc_id = aws_vpc.main.id

  tags = merge(
    {
      Name = "${var.project_name}-igw"
    },
    var.tags
  )
}

resource "aws_route_table" "public" {
  vpc_id = aws_vpc.main.id

  tags = merge(
    {
      Name = "${var.project_name}-public-rt"
    },
    var.tags
  )
}

resource "aws_route" "default_route" {
  route_table_id         = aws_route_table.public.id
  destination_cidr_block = "0.0.0.0/0"
  gateway_id             = aws_internet_gateway.main.id
}

resource "aws_route_table_association" "public" {
  count          = length(aws_subnet.public)
  subnet_id      = aws_subnet.public[count.index].id
  route_table_id = aws_route_table.public.id
}
