# terraform-aws-route53-resolver-endpoint

Terraform module for a Route53 Resolver endpoint — the ENIs that let DNS
queries cross between a VPC and an outside network (on-premises, another
VPC, or another cloud).

## Cost

The endpoint bills hourly per ENI it creates (one per subnet listed in
`ip_addresses`), plus a per-million-queries charge for DNS queries it
processes. See AWS's
[Route53 Resolver pricing](https://aws.amazon.com/route53/pricing/#Route_53_Resolver_endpoints_for_DNS_query_logging_and_DNS_Firewall)
page for current rates.

## Design

An `'OUTBOUND'` endpoint is what
[`terraform-aws-route53-resolver-rule`](https://github.com/kn47ytv9mv/terraform-aws-route53-resolver-rule)'s
forwarding rules need to actually send DNS queries out of the VPC — one
outbound endpoint typically backs several rules, which is why this module
creates only the endpoint itself and not the rules that use it, mirroring
this family's `terraform-aws-alb`/`terraform-aws-alb-target-group` split
for the same not-1:1 reason. An `'INBOUND'` endpoint is the reverse: it
lets DNS queries from outside the VPC (on-premises, or another VPC using
this VPC as an authoritative resolver) reach the VPC's own DNS.

`ip_addresses` is validated to have at least two entries, once any are
given — AWS requires an endpoint's ENIs to span at least two
availability zones. Like `terraform-aws-alb`'s equivalent check, this
only verifies the count; it cannot confirm the subnets are actually in
different AZs without an extra `data` source lookup this module
deliberately avoids.

## Usage

```hcl
module "resolver_outbound" {
  source = "kn47ytv9mv/route53-resolver-endpoint/aws"

  direction          = "OUTBOUND"
  security_group_ids = [module.security_group.id]

  ip_addresses = [
    { subnet_id = module.vpc.subnet_ids["private"][0] },
    { subnet_id = module.vpc.subnet_ids["private"][1] },
  ]
}
```

Or directly from this repository:

```hcl
module "resolver_inbound" {
  source = "github.com/kn47ytv9mv/terraform-aws-route53-resolver-endpoint"

  direction          = "INBOUND"
  security_group_ids = [module.security_group.id]

  ip_addresses = [
    { subnet_id = module.vpc.subnet_ids["private"][0] },
    { subnet_id = module.vpc.subnet_ids["private"][1] },
  ]
}
```

## Requirements

| Name | Version |
|---|---|
| terraform | >= 1.3 |
| aws | ~> 6.61 |

## Providers

| Name | Version |
|---|---|
| aws | ~> 6.61 |

## Inputs

| Name | Description | Default | Required |
|---|---|---|---|
| direction | Direction of DNS queries the endpoint handles: `'INBOUND'` (from outside the VPC to it), `'OUTBOUND'` (from the VPC to your network or another VPC, required by `terraform-aws-route53-resolver-rule`'s forwarding rules), or `'INBOUND_DELEGATION'`. | `null` | no |
| security_group_ids | IDs of the security groups to associate with the endpoint's ENIs. | `null` | no |
| ip_addresses | Subnets to place the endpoint's ENIs in — one entry per availability zone, AWS requires at least two. Each entry needs `subnet_id`; `ip` and `ipv6` are optional and, if unset, AWS assigns an address automatically. | `[]` | no |
| resolver_endpoint_type | Address family for the endpoint's ENIs (`'IPV4'`, `'IPV6'`, or `'DUALSTACK'`). If null, AWS's own default applies. | `null` | no |
| protocols | DNS protocols the endpoint supports (`'Do53'`, `'DoH'`, `'DoH-FIPS'`). If null, AWS's own default applies. | `null` | no |
| tags | A map of tags to assign to the resolver endpoint. | `null` | no |

## Outputs

| Name | Description |
|---|---|
| id | The ID of the resolver endpoint. |
| arn | The ARN of the resolver endpoint. |
| host_vpc_id | The ID of the VPC the endpoint's ENIs were created in. |

## License

MIT — see [LICENSE.md](LICENSE.md).
