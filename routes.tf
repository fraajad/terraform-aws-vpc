locals {
  public_network_subnets  = { for k, v in local.network_subnets : k => v if v.type == "public" }
  private_network_subnets = { for k, v in local.network_subnets : k => v if v.type == "private" }
}

resource "aws_route_table" "this" {
  for_each = local.network_subnets

  vpc_id = aws_vpc.this.id

  tags = merge(
    module.label.tags,
    {
      Name = "${module.label.id}-${each.value.key}-${each.value.availability_zone}"
      AZ   = each.value.availability_zone
      Type = each.value.type
    },
  )
}

resource "aws_route_table_association" "this" {
  for_each = local.network_subnets

  subnet_id      = aws_subnet.this[each.key].id
  route_table_id = aws_route_table.this[each.key].id

  depends_on = [
    aws_subnet.this,
    aws_route_table.this,
  ]
}

resource "aws_route" "private_default" {
  for_each = length(aws_nat_gateway.this) > 0 ? local.private_network_subnets : {}

  route_table_id = aws_route_table.this[each.key].id
  nat_gateway_id = lookup(
    { for k, v in aws_nat_gateway.this : local.network_subnets[k].availability_zone => v.id },
    each.value.availability_zone
  )
  destination_cidr_block = "0.0.0.0/0"

  depends_on = [aws_route_table.this]
}

resource "aws_route" "public_default" {
  for_each = local.public_network_subnets

  route_table_id         = aws_route_table.this[each.key].id
  gateway_id             = aws_internet_gateway.default.id
  destination_cidr_block = "0.0.0.0/0"

  depends_on = [aws_route_table.this]
}

resource "aws_eip" "nat" {
  for_each = var.nat_gateway_enabled ? local.public_network_subnets : {}

  vpc = true

  lifecycle {
    create_before_destroy = true
  }
}
resource "aws_nat_gateway" "this" {
  for_each = var.nat_gateway_enabled ? local.public_network_subnets : {}

  allocation_id = aws_eip.nat[each.key].id
  subnet_id     = aws_subnet.this[each.key].id
  depends_on    = [aws_subnet.this]

  lifecycle {
    create_before_destroy = true
  }

  tags = merge(
    module.label.tags,
    {
      Name = "${module.label.id}-${each.value.availability_zone}"
      AZ   = each.value.availability_zone
    },
  )
}
