variable "namespace" {
  type        = string
  description = "Namespace (e.g. `eg`)"
}

variable "environment" {
  type        = string
  default     = ""
  description = "Environment, e.g. 'prod', 'staging', 'dev'"
}

variable "stage" {
  type        = string
  description = "Stage (e.g. `prod`, `dev`, `staging`)"
}

variable "name" {
  type        = string
  description = "VPC name"
  default     = "main"
}

variable "delimiter" {
  type        = string
  default     = "-"
  description = "Delimiter to be used between `namespace`, `environment`, `stage`, `name` and `attributes`"
}

variable "attributes" {
  type        = list(string)
  default     = ["vpc"]
  description = "Additional attributes (e.g. `1`)"
}

variable "tags" {
  type        = map(string)
  default     = {}
  description = "Additional tags (e.g. map(`BusinessUnit`,`XYZ`)"
}

variable "availability_zones" {
  type        = list(string)
  description = "List of Availability Zones (e.g. `['us-east-1a', 'us-east-1b', 'us-east-1c']`)"
}

variable "cidr_block" {
  default = "10.0.0.0/16"
}

variable "network" {
  type = map(map(string))
  default = {
    public = {
      cidr_block = "10.0.0.0/18"
      type       = "public"
    }
    private = {
      cidr_block = "10.0.64.0/18"
      type       = "private"
    }
  }
}

variable "public_network_acl_egress" {
  description = "Egress network ACL rules"
  type        = list(map(string))

  default = [
    {
      rule_no    = 100
      action     = "allow"
      cidr_block = "0.0.0.0/0"
      from_port  = 0
      to_port    = 0
      protocol   = "-1"
    },
  ]
}

variable "public_network_acl_ingress" {
  description = "Egress network ACL rules"
  type        = list(map(string))

  default = [
    {
      rule_no    = 100
      action     = "allow"
      cidr_block = "0.0.0.0/0"
      from_port  = 0
      to_port    = 0
      protocol   = "-1"
    },
  ]
}

variable "private_network_acl_egress" {
  description = "Egress network ACL rules"
  type        = list(map(string))

  default = [
    {
      rule_no    = 100
      action     = "allow"
      cidr_block = "0.0.0.0/0"
      from_port  = 0
      to_port    = 0
      protocol   = "-1"
    },
  ]
}

variable "private_network_acl_ingress" {
  description = "Egress network ACL rules"
  type        = list(map(string))

  default = [
    {
      rule_no    = 100
      action     = "allow"
      cidr_block = "0.0.0.0/0"
      from_port  = 0
      to_port    = 0
      protocol   = "-1"
    },
  ]
}

variable "nat_gateway_enabled" {
  description = "A boolean flag to enable/disable NAT gateway as the default route for private subnets"
  type        = bool
  default     = true
}

variable "vpc_endpoints_enabled" {
  type    = bool
  default = false
}

variable "vpc_endpoints" {
  type = list(string)

  default = []
}

variable "vpc_endpoint_interface_network" {
  type    = string
  default = "private"
}

variable "vpc_flow_logs_bucket_name" {
  type    = string
  default = ""
}

variable "private_subnets_additional_tags" {
  type        = map(string)
  default     = {}
  description = "Additional tags to be added to private subnets"
}

variable "public_subnets_additional_tags" {
  type        = map(string)
  default     = {}
  description = "Additional tags to be added to public subnets"
}
