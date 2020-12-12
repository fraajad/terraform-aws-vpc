locals {
  az_count = length(var.availability_zones)
  networks = [
    for key, network in var.network : {
      key     = key
      network = network
    }
  ]
  network_subnet_product = [
    # in pair, element zero is a network and element one is a subnet,
    # in all unique combinations.
    for pair in setproduct(local.networks, var.availability_zones) : {
      key               = pair[0].key
      type              = lookup(pair[0].network, "type", "private")
      cidr_block        = pair[0].network.cidr_block
      availability_zone = pair[1]
      az_index          = index(var.availability_zones, pair[1])
    }
  ]
  network_subnets = { for x in local.network_subnet_product : "${x.key}.${x.availability_zone}" => x }
}

data "aws_region" "this" {}

module "label" {
  source      = "git::https://github.com/cloudposse/terraform-null-label.git?ref=tags/0.19.2"
  namespace   = var.namespace
  name        = var.name
  stage       = var.stage
  environment = var.environment
  delimiter   = var.delimiter
  attributes  = var.attributes
  tags        = var.tags
}

resource "aws_vpc" "this" {
  cidr_block = var.cidr_block

  enable_dns_hostnames             = true
  enable_dns_support               = true
  assign_generated_ipv6_cidr_block = false

  tags = module.label.tags
}

resource "aws_default_security_group" "this" {
  vpc_id = aws_vpc.this.id

  tags = {
    Name = "${module.label.id}-default"
  }
}

resource "aws_subnet" "this" {
  for_each = local.network_subnets

  vpc_id            = aws_vpc.this.id
  availability_zone = each.value.availability_zone
  cidr_block = cidrsubnet(
    each.value.cidr_block,
    ceil(log(local.az_count, 2)),
    each.value.az_index
  )

  tags = merge(
    each.value.type == "private" ? var.private_subnets_additional_tags : {},
    each.value.type == "public" ? var.public_subnets_additional_tags : {},
    module.label.tags,
    {
      Name = "${module.label.id}-${each.value.key}-${each.value.availability_zone}"
      AZ   = each.value.availability_zone
      Type = each.value.type
    },
  )
}

resource "aws_internet_gateway" "default" {
  vpc_id = aws_vpc.this.id

  tags = {
    Name = module.label.id
  }
}

resource "aws_flow_log" "vpc" {
  count = var.vpc_flow_logs_bucket_name != "" ? 1 : 0

  log_destination      = "arn:aws:s3:::${var.vpc_flow_logs_bucket_name}"
  log_destination_type = "s3"
  traffic_type         = "ALL"
  vpc_id               = aws_vpc.this.id
}
