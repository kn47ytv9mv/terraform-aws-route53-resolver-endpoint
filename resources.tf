resource "aws_route53_resolver_endpoint" "resource" {
  direction              = var.direction
  security_group_ids     = var.security_group_ids
  resolver_endpoint_type = var.resolver_endpoint_type
  protocols              = var.protocols

  dynamic "ip_address" {
    for_each = var.ip_addresses

    content {
      subnet_id = ip_address.value.subnet_id
      ip        = ip_address.value.ip
      ipv6      = ip_address.value.ipv6
    }
  }

  tags = merge(var.tags, { name = "resolver-endpoint" })
}

output "id" {
  description = "The ID of the resolver endpoint."
  value       = aws_route53_resolver_endpoint.resource.id
}

output "arn" {
  description = "The ARN of the resolver endpoint."
  value       = aws_route53_resolver_endpoint.resource.arn
}

output "host_vpc_id" {
  description = "The ID of the VPC the endpoint's ENIs were created in."
  value       = aws_route53_resolver_endpoint.resource.host_vpc_id
}
