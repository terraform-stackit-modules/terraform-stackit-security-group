#####################################################################################
# Terraform module examples are meant to show an _example_ on how to use a module
# per use-case. The code below should not be copied directly but referenced in order
# to build your own root module that invokes this module
#####################################################################################

module "security_group" {
  source = "../.."

  project_id  = var.project_id
  name        = "example-sg"
  description = "Example security group: allow inbound HTTPS, allow all egress"

  labels = {
    managed_by = "terraform"
    example    = "basic"
  }

  rules = [
    {
      name       = "https-ingress"
      direction  = "ingress"
      ether_type = "IPv4"
      ip_range   = "0.0.0.0/0"
      protocol   = { name = "tcp" }
      port_range = { min = 443, max = 443 }
    },
    {
      name       = "all-egress"
      direction  = "egress"
      ether_type = "IPv4"
      ip_range   = "0.0.0.0/0"
    },
  ]
}
