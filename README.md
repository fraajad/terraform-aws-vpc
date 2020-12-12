# terraform-aws-vpc
This `vpc` module enables the dynamic creation of subnets and vpc endpoints.

The module design was inspired by the excellent module [cloudposse/terraform-aws-multi-az-subnets](https://github.com/cloudposse/terraform-aws-multi-az-subnets).

## Example configuration

```
data "aws_availability_zones" "available" {}

locals {
  namespace            = "fraajad"
  stage                = "dev"
  name                 = "main"
  account_network_cidr = "10.128.0.0/16"
}

module "vpc" {
  source = "git::https://github.com/fraajad/terraform-aws-vpc.git?ref=master"

  namespace           = local.namespace
  stage               = local.stage
  name                = local.name
  availability_zones  = slice(data.aws_availability_zones.available.names, 0, 3)
  cidr_block          = local.account_network_cidr
  network = {
    public = {
      cidr_block = cidrsubnet(local.account_network_cidr, 2, 0)
      type       = "public"
    }
    private = {
      cidr_block = cidrsubnet(local.account_network_cidr, 2, 1)
      type       = "private"
    }
  }
  public_subnets_additional_tags = {
    "kubernetes.io/cluster/${local.namespace}-${local.stage}-eks-cluster" = "shared"
    "kubernetes.io/role/elb"                                              = "1"
  }
  private_subnets_additional_tags = {
    "kubernetes.io/cluster/${local.namespace}-${local.stage}-eks-cluster" = "shared"
    "kubernetes.io/role/internal-elb"                                     = "1"
  }
  vpc_endpoints_enabled     = true
  vpc_endpoints             = [
    "ec2",
    "ecr-api",
    "ecr.dkr",
    "s3",
    "logs",
    "sts",
    "elasticloadbalancing",
    "autoscaling"
  ]
}
```

```
Outputs:

vpcs = {
  "main" = {
    "availability_zones" = [
      "us-west-2a",
      "us-west-2b",
      "us-west-2c",
    ]
    "cidr_block" = "10.128.0.0/16"
    "default_security_group_id" = "sg-xxxxxxxxxxxxx"
    "igw_id" = "igw-xxxxxxxxxxxxx"
    "nat_gateway_ips" = [
      "xx.xx.xx.xx",
      "xx.xx.xx.xx",
      "xx.xx.xx.xx",
    ]
    "networks" = {
      "private" = {
        "cidr_block" = "10.128.64.0/18"
        "route_table_ids" = [
          "rtb-xxxxxxxxxxxxx",
          "rtb-xxxxxxxxxxxxx",
          "rtb-xxxxxxxxxxxxx",
        ]
        "subnet_ids" = [
          "subnet-xxxxxxxxxxxxx",
          "subnet-xxxxxxxxxxxxx",
          "subnet-xxxxxxxxxxxxx",
        ]
        "type" = "private"
      }
      "public" = {
        "cidr_block" = "10.128.0.0/20"
        "route_table_ids" = [
          "rtb-xxxxxxxxxxxxx",
          "rtb-xxxxxxxxxxxxx",
          "rtb-xxxxxxxxxxxxx",
        ]
        "subnet_ids" = [
          "subnet-xxxxxxxxxxxxx",
          "subnet-xxxxxxxxxxxxx",
          "subnet-xxxxxxxxxxxxx",
        ]
        "type" = "public"
      }
    }
    "vpc_id" = "vpc-xxxxxxxxxxxxx"
  }
}
```

<!-- BEGINNING OF PRE-COMMIT-TERRAFORM DOCS HOOK -->
## Requirements

No requirements.

## Providers

| Name | Version |
|------|---------|
| aws | n/a |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| availability\_zones | List of Availability Zones (e.g. `['us-east-1a', 'us-east-1b', 'us-east-1c']`) | `list(string)` | n/a | yes |
| namespace | Namespace (e.g. `eg`) | `string` | n/a | yes |
| stage | Stage (e.g. `prod`, `dev`, `staging`) | `string` | n/a | yes |
| attributes | Additional attributes (e.g. `1`) | `list(string)` | <pre>[<br>  "vpc"<br>]</pre> | no |
| cidr\_block | n/a | `string` | `"10.0.0.0/16"` | no |
| delimiter | Delimiter to be used between `namespace`, `environment`, `stage`, `name` and `attributes` | `string` | `"-"` | no |
| environment | Environment, e.g. 'prod', 'staging', 'dev' | `string` | `""` | no |
| name | VPC name | `string` | `"main"` | no |
| nat\_gateway\_enabled | A boolean flag to enable/disable NAT gateway as the default route for private subnets | `bool` | `true` | no |
| network | n/a | `map(map(string))` | <pre>{<br>  "private": {<br>    "cidr_block": "10.0.64.0/18",<br>    "type": "private"<br>  },<br>  "public": {<br>    "cidr_block": "10.0.0.0/18",<br>    "type": "public"<br>  }<br>}</pre> | no |
| private\_network\_acl\_egress | Egress network ACL rules | `list(map(string))` | <pre>[<br>  {<br>    "action": "allow",<br>    "cidr_block": "0.0.0.0/0",<br>    "from_port": 0,<br>    "protocol": "-1",<br>    "rule_no": 100,<br>    "to_port": 0<br>  }<br>]</pre> | no |
| private\_network\_acl\_ingress | Egress network ACL rules | `list(map(string))` | <pre>[<br>  {<br>    "action": "allow",<br>    "cidr_block": "0.0.0.0/0",<br>    "from_port": 0,<br>    "protocol": "-1",<br>    "rule_no": 100,<br>    "to_port": 0<br>  }<br>]</pre> | no |
| private\_subnets\_additional\_tags | Additional tags to be added to private subnets | `map(string)` | `{}` | no |
| public\_network\_acl\_egress | Egress network ACL rules | `list(map(string))` | <pre>[<br>  {<br>    "action": "allow",<br>    "cidr_block": "0.0.0.0/0",<br>    "from_port": 0,<br>    "protocol": "-1",<br>    "rule_no": 100,<br>    "to_port": 0<br>  }<br>]</pre> | no |
| public\_network\_acl\_ingress | Egress network ACL rules | `list(map(string))` | <pre>[<br>  {<br>    "action": "allow",<br>    "cidr_block": "0.0.0.0/0",<br>    "from_port": 0,<br>    "protocol": "-1",<br>    "rule_no": 100,<br>    "to_port": 0<br>  }<br>]</pre> | no |
| public\_subnets\_additional\_tags | Additional tags to be added to public subnets | `map(string)` | `{}` | no |
| tags | Additional tags (e.g. map(`BusinessUnit`,`XYZ`) | `map(string)` | `{}` | no |
| vpc\_endpoint\_interface\_network | n/a | `string` | `"private"` | no |
| vpc\_endpoints | n/a | `list(string)` | `[]` | no |
| vpc\_endpoints\_enabled | n/a | `bool` | `false` | no |
| vpc\_flow\_logs\_bucket\_name | n/a | `string` | `""` | no |

## Outputs

| Name | Description |
|------|-------------|
| availability\_zones | List of Availability Zones where subnets were created |
| cidr\_block | The CIDR block of the VPC |
| default\_security\_group\_id | The ID of the security group created by default on VPC creation |
| igw\_id | The ID of the Internet Gateway |
| nat\_gateway\_ips | IP addresses of the NAT Gateways |
| network | Map of network attributes |
| vpc\_endpoint\_interface\_network | n/a |
| vpc\_id | The ID of the VPC |

<!-- END OF PRE-COMMIT-TERRAFORM DOCS HOOK -->
