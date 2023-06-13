terraform {
  required_providers {
    singapore = {
      source  = "hashicorp/aws"
      version = "3.66"
    }
  }
}

data "aws_vpc" "vpc_privateSubnets" {
  count = length(var.private_subnets_singapore[*])
  filter {
    name = "tag:Name"
    values = [element(var.private_subnets_singapore[*]["vpc_name"],count.index)]
  }
}

locals {
  vpc_id_private = data.aws_vpc.vpc_privateSubnets.*.id
}

#Private Subnet Creation
resource "aws_subnet" "private_subnet" {
  count = length(var.private_subnets_singapore[*])
  #vpc_id     = element(var.vpc_id,count.index)
  vpc_id     = element(local.vpc_id_private,count.index)
  cidr_block = element(var.private_subnets_singapore[*]["CIDR"],count.index)
  availability_zone = element(var.private_subnets_singapore[*]["availability_zone"],count.index)
  map_public_ip_on_launch = true
  tags = {
    Name  = format("%s",element(var.private_subnets_singapore[*]["subnet_name"],count.index))
    Environment = var.environment
  }
}

output "private_subnet_id" {
  value = aws_subnet.private_subnet.*.id
}