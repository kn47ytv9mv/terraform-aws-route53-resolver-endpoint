variable "direction" {
  default     = null
  description = "Direction of DNS queries the endpoint handles: 'INBOUND' (from outside the VPC to it), 'OUTBOUND' (from the VPC to your network or another VPC, required by terraform-aws-route53-resolver-rule's forwarding rules), or 'INBOUND_DELEGATION'."

  validation {
    condition     = var.direction == null || contains(["INBOUND", "OUTBOUND", "INBOUND_DELEGATION"], var.direction)
    error_message = "direction must be 'INBOUND', 'OUTBOUND', or 'INBOUND_DELEGATION'."
  }
}

variable "security_group_ids" {
  default     = null
  description = "IDs of the security groups to associate with the endpoint's ENIs."
}

variable "ip_addresses" {
  default     = []
  description = "Subnets to place the endpoint's ENIs in — one entry per availability zone, AWS requires at least two. Each entry needs subnet_id; ip and ipv6 are optional and, if unset, AWS assigns an address automatically."
  type = list(object({
    subnet_id = string
    ip        = optional(string)
    ipv6      = optional(string)
  }))

  validation {
    condition     = length(var.ip_addresses) == length(distinct([for a in var.ip_addresses : a.subnet_id]))
    error_message = "Each ip_addresses entry's subnet_id must be unique."
  }

  validation {
    condition     = length(var.ip_addresses) == 0 || length(var.ip_addresses) >= 2
    error_message = "ip_addresses needs at least two entries, in different availability zones, once any are given — AWS requires this for a resolver endpoint's ENIs. This only checks the count, not that the subnets are actually in different AZs."
  }
}

variable "resolver_endpoint_type" {
  default     = null
  description = "Address family for the endpoint's ENIs ('IPV4', 'IPV6', or 'DUALSTACK'). If null, AWS's own default applies."
}

variable "protocols" {
  default     = null
  description = "DNS protocols the endpoint supports ('Do53', 'DoH', 'DoH-FIPS'). If null, AWS's own default applies."
}

variable "tags" {
  default     = null
  description = "A map of tags to assign to the resolver endpoint."
}
