output "security_group_id" {
  description = "The ID of the security group created by the example."
  value       = module.security_group.security_group_id
}

output "security_group_name" {
  description = "The name of the security group created by the example."
  value       = module.security_group.security_group_name
}

output "rule_ids" {
  description = "Map of rule key to security group rule ID created by the example."
  value       = module.security_group.rule_ids
}
