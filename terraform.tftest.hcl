mock_provider "aws" {
}

run "direction_invalid_rejected" {
  command = plan

  variables {
    direction          = "SIDEWAYS"
    security_group_ids = ["sg-0123456789abcdef0"]
  }

  expect_failures = [var.direction]
}

run "duplicate_subnet_id_rejected" {
  command = plan

  variables {
    direction          = "OUTBOUND"
    security_group_ids = ["sg-0123456789abcdef0"]
    ip_addresses = [
      { subnet_id = "subnet-0123456789abcdef0" },
      { subnet_id = "subnet-0123456789abcdef0" },
    ]
  }

  expect_failures = [var.ip_addresses]
}

run "fewer_than_two_ip_addresses_rejected" {
  command = plan

  variables {
    direction          = "OUTBOUND"
    security_group_ids = ["sg-0123456789abcdef0"]
    ip_addresses = [
      { subnet_id = "subnet-0123456789abcdef0" },
    ]
  }

  expect_failures = [var.ip_addresses]
}

run "endpoint_created_with_two_azs" {
  command = apply

  variables {
    direction          = "OUTBOUND"
    security_group_ids = ["sg-0123456789abcdef0"]
    ip_addresses = [
      { subnet_id = "subnet-aaaaaaaaaaaaaaaaa" },
      { subnet_id = "subnet-bbbbbbbbbbbbbbbbb", ip = "10.0.2.10" },
    ]
  }

  assert {
    condition     = aws_route53_resolver_endpoint.resource.direction == "OUTBOUND"
    error_message = "direction should pass through unchanged."
  }

  assert {
    condition     = length(aws_route53_resolver_endpoint.resource.ip_address) == 2
    error_message = "One ip_address block should be created per entry in ip_addresses."
  }
}

run "readme_outbound_example" {
  command = plan

  variables {
    direction          = "OUTBOUND"
    security_group_ids = ["sg-0123456789abcdef0"]
    ip_addresses = [
      { subnet_id = "subnet-aaaaaaaaaaaaaaaaa" },
      { subnet_id = "subnet-bbbbbbbbbbbbbbbbb" },
    ]
  }
}

run "readme_inbound_example" {
  command = plan

  variables {
    direction          = "INBOUND"
    security_group_ids = ["sg-0123456789abcdef0"]
    ip_addresses = [
      { subnet_id = "subnet-aaaaaaaaaaaaaaaaa" },
      { subnet_id = "subnet-bbbbbbbbbbbbbbbbb" },
    ]
  }
}
