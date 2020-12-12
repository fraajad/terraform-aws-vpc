locals {
  vpce_subnets = [for k, v in aws_subnet.this : v.id if split(".", k)[0] == var.vpc_endpoint_interface_network]
}

resource "aws_security_group" "vpce" {
  count = var.vpc_endpoints_enabled ? 1 : 0

  name        = "${module.label.id}-endpoints"
  description = "Allow Access to VPC endpoints"

  vpc_id = aws_vpc.this.id

  ingress {
    from_port   = 0
    to_port     = 0
    protocol    = -1
    cidr_blocks = [var.cidr_block]
  }

  tags = module.label.tags

  lifecycle {
    create_before_destroy = true
  }
}

data "aws_vpc_endpoint_service" "service" {
  for_each = var.vpc_endpoints_enabled ? toset(var.vpc_endpoints) : toset([])

  service      = length(split(".", each.value)) <= 2 ? each.value : null
  service_name = length(split(".", each.value)) > 2 ? each.value : null
}

resource "aws_vpc_endpoint" "endpoint" {
  for_each = var.vpc_endpoints_enabled ? toset(var.vpc_endpoints) : toset([])

  service_name        = data.aws_vpc_endpoint_service.service[each.key].service_name
  vpc_endpoint_type   = data.aws_vpc_endpoint_service.service[each.key].service_type
  private_dns_enabled = data.aws_vpc_endpoint_service.service[each.key].service_type == "Interface" ? true : null
  vpc_id              = aws_vpc.this.id
  subnet_ids          = data.aws_vpc_endpoint_service.service[each.key].service_type == "Interface" ? local.vpce_subnets : null
  security_group_ids  = data.aws_vpc_endpoint_service.service[each.key].service_type == "Interface" ? [aws_security_group.vpce[0].id] : null

  tags = module.label.tags
}

resource "aws_vpc_endpoint_route_table_association" "s3" {
  for_each = var.vpc_endpoints_enabled && contains(var.vpc_endpoints, "s3") ? aws_route_table.this : {}

  vpc_endpoint_id = aws_vpc_endpoint.endpoint["s3"].id
  route_table_id  = aws_route_table.this[each.key].id
}
