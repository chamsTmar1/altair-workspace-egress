output "nat_gateway_eip" {
  description = "Elastic IP of NAT Gateway (provide this to Altair for whitelisting)"
  value       = aws_eip.nat.public_ip
}

output "vpc_id" {
  description = "VPC ID"
  value       = aws_vpc.main.id
}

output "workspaces_subnet_ids" {
  description = "Subnet IDs for WorkSpaces directory configuration"
  value       = [aws_subnet.private_ws_1.id, aws_subnet.private_ws_2.id]
}

output "availability_zones" {
  description = "Availability Zones used"
  value = {
    primary   = local.az_primary
    secondary = local.az_secondary
  }
}

output "deployment_summary" {
  description = "Deployment summary"
  value       = <<-EOT
    
    ========================================
    Altair WorkSpaces Egress - Deployment Summary
    ========================================
    
    NAT Gateway Public IP (for Altair whitelist): ${aws_eip.nat.public_ip}
    VPC ID: ${aws_vpc.main.id}
    Region: ${var.aws_region}
    
    Network Configuration:
      - NAT Gateway in: ${local.az_primary}
      - WorkSpaces subnet 1: ${local.az_primary} (${var.private_subnet_1_cidr})
      - WorkSpaces subnet 2: ${local.az_secondary} (${var.private_subnet_2_cidr})
      - Note: Cross-AZ data transfer charges apply for traffic from ${local.az_secondary}
    
    WorkSpaces Subnets (use these when creating Simple AD directory):
      - ${aws_subnet.private_ws_1.id} (${var.private_subnet_1_cidr}) in ${local.az_primary}
      - ${aws_subnet.private_ws_2.id} (${var.private_subnet_2_cidr}) in ${local.az_secondary}
    
    ========================================
  EOT
}
