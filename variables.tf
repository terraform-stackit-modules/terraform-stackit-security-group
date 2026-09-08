# ─── Security Group ───────────────────────────────────────────────────────────

variable "project_id" {
  description = "STACKIT project ID in which the security group and its rules are created."
  type        = string
}

variable "create_security_group" {
  description = "Whether to create the security group and its rules. Set to false to disable all resources in this module."
  type        = bool
  default     = true
}

variable "name" {
  description = "The name of the security group."
  type        = string
}

variable "description" {
  description = "The description of the security group."
  type        = string
  default     = null
}

variable "region" {
  description = "The resource region. If not defined, the provider region is used."
  type        = string
  default     = null
}

variable "stateful" {
  description = "Whether the security group is stateful (connection tracking). There can only be one type of security group per network interface/server."
  type        = bool
  default     = null
}

variable "labels" {
  description = "Key-value string pairs to attach to the security group."
  type        = map(string)
  default     = {}
}

# ─── Rules ────────────────────────────────────────────────────────────────────

variable "rules" {
  description = <<-EOT
    List of security group rules to attach to the security group.

    Each rule requires a `direction` (`ingress` or `egress`) and an `ether_type` (e.g. `IPv4`, `IPv6`).
    All other fields are optional:
      - `name`                     : stable key for the rule (used for `for_each`); defaults to `<direction>-<index>`.
      - `description`              : free-text rule description.
      - `ip_range`                 : remote IP range in CIDR notation the rule matches.
      - `remote_security_group_id` : remote security group the rule matches (mutually exclusive with `ip_range`).
      - `protocol`                 : `{ name = "tcp" }` OR `{ number = 6 }` — provide exactly one of `name`/`number`.
      - `port_range`               : `{ min = <n>, max = <n> }` — only for non-ICMP protocols.
      - `icmp_parameters`          : `{ code = <n>, type = <n> }` — only when the protocol is ICMP.
  EOT
  type = list(object({
    direction                = string
    ether_type               = string
    name                     = optional(string)
    description              = optional(string)
    ip_range                 = optional(string)
    remote_security_group_id = optional(string)
    protocol = optional(object({
      name   = optional(string)
      number = optional(number)
    }))
    port_range = optional(object({
      min = number
      max = number
    }))
    icmp_parameters = optional(object({
      code = number
      type = number
    }))
  }))
  default = []

  validation {
    condition     = alltrue([for r in var.rules : contains(["ingress", "egress"], r.direction)])
    error_message = "Each rule must have a direction of either \"ingress\" or \"egress\"."
  }

  validation {
    condition = alltrue([
      for r in var.rules :
      !(try(r.protocol.name, null) != null && try(r.protocol.number, null) != null)
    ])
    error_message = "In a rule protocol, provide either \"name\" or \"number\", not both."
  }

  validation {
    condition = alltrue([
      for r in var.rules :
      try(r.protocol.name, null) == null ||
      contains(["ah", "dccp", "egp", "esp", "gre", "icmp", "igmp", "ipip", "ipv6-encap", "ipv6-frag", "ipv6-icmp", "ipv6-nonxt", "ipv6-opts", "ipv6-route", "ospf", "pgm", "rsvp", "sctp", "tcp", "udp", "udplite", "vrrp"], try(r.protocol.name, ""))
    ])
    error_message = "protocol.name must be lowercase and one of: ah, dccp, egp, esp, gre, icmp, igmp, ipip, ipv6-encap, ipv6-frag, ipv6-icmp, ipv6-nonxt, ipv6-opts, ipv6-route, ospf, pgm, rsvp, sctp, tcp, udp, udplite, vrrp."
  }

  validation {
    condition = alltrue([
      for r in var.rules :
      !(r.ip_range != null && r.remote_security_group_id != null)
    ])
    error_message = "A rule may set either \"ip_range\" or \"remote_security_group_id\", not both."
  }
}
