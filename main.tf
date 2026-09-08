resource "stackit_security_group" "this" {
  count = var.create_security_group ? 1 : 0

  project_id  = var.project_id
  region      = var.region
  name        = var.name
  description = var.description
  stateful    = var.stateful
  labels      = var.labels
}

resource "stackit_security_group_rule" "this" {
  for_each = var.create_security_group ? {
    for idx, rule in var.rules : coalesce(rule.name, "${rule.direction}-${idx}") => rule
  } : {}

  project_id               = var.project_id
  region                   = var.region
  security_group_id        = stackit_security_group.this[0].security_group_id
  direction                = each.value.direction
  description              = each.value.description
  ether_type               = each.value.ether_type
  ip_range                 = each.value.ip_range
  remote_security_group_id = each.value.remote_security_group_id

  protocol        = each.value.protocol
  port_range      = each.value.port_range
  icmp_parameters = each.value.icmp_parameters
}
