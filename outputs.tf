output "availability_zones" {
  description = "List of Availability Zones where subnets were created"
  value       = var.availability_zones
}

output "igw_id" {
  value       = aws_internet_gateway.default.id
  description = "The ID of the Internet Gateway"
}

output "vpc_id" {
  value       = aws_vpc.this.id
  description = "The ID of the VPC"
}

output "cidr_block" {
  value       = aws_vpc.this.cidr_block
  description = "The CIDR block of the VPC"
}

output "default_security_group_id" {
  value       = aws_default_security_group.this.id
  description = "The ID of the security group created by default on VPC creation"
}

output "nat_gateway_ips" {
  description = "IP addresses of the NAT Gateways"
  value       = [for x in aws_eip.nat : x.public_ip]
}

output "network" {
  description = "Map of network attributes"
  value = {
    for key, network in var.network : key => {
      type            = network.type
      cidr_block      = network.cidr_block
      route_table_ids = [for k, v in aws_route_table.this : v.id if split(".", k)[0] == key]
      subnet_ids      = [for k, v in aws_subnet.this : v.id if split(".", k)[0] == key]
    }
  }
}

output "vpc_endpoint_interface_network" {
  value = var.vpc_endpoints_enabled ? var.vpc_endpoint_interface_network : null
}
