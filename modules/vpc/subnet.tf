locals {
  total_subnet_count = var.public_subnet_count + var.private_subnet_count
  subnet_cidr_blocks = [for index in range(local.total_subnet_count) :
    cidrsubnet(var.vpc_cidr_block,
      ceil(log(local.total_subnet_count, 2)),
  index)]
}

data "aws_availability_zones" "available" {
  state = "available"
}

resource "aws_subnet" "public_subnet" {
  count                   = var.public_subnet_count
  vpc_id                  = aws_vpc.my_vpc.id
  cidr_block              = local.subnet_cidr_blocks[count.index]
  availability_zone       = data.aws_availability_zones.available.names[count.index]
  map_public_ip_on_launch = true

  tags = {
    Name = "public-subnet-${count.index}"
  }
}

resource "aws_subnet" "private_subnet" {
  count             = var.private_subnet_count
  vpc_id            = aws_vpc.my_vpc.id
  cidr_block        = local.subnet_cidr_blocks[var.public_subnet_count + count.index]
  availability_zone = data.aws_availability_zones.available.names[count.index]

  tags = {
    Name = "private-subnet-${count.index}"
  }
}
