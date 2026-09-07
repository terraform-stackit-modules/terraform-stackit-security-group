output "security_group_id" {
  description = "The ID of the created security group (null when create_security_group is false)."
  value       = var.create_security_group ? stackit_security_group.this[0].security_group_id : null
}

output "security_group_name" {
  description = "The name of the created security group (null when create_security_group is false)."
  value       = var.create_security_group ? stackit_security_group.this[0].name : null
}

output "rule_ids" {
  description = "Map of rule key to security group rule ID for every rule created by this module."
  value       = { for k, r in stackit_security_group_rule.this : k => r.security_group_rule_id }
}
