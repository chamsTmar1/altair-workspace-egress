# Altair WorkSpaces Egress Solution

Single-IP egress solution for AWS WorkSpaces to access Altair API.

## Problem
Altair whitelists only specific public IPs. WorkSpaces need a stable, single egress IP.

## Solution
Route all WorkSpaces traffic through a NAT Gateway with one Elastic IP.

## Architecture
- VPC in single AZ (single EIP requirement)
- Public subnet: NAT Gateway + Internet Gateway
- Private subnets: WorkSpaces instances
- All WorkSpaces egress → NAT Gateway → Internet (via single EIP)

## Prerequisites
- AWS CLI configured with appropriate credentials
- Terraform >= 1.0
- AWSPowerUserAccess (minimum) + WorkSpaces permissions

## Deployment

### 1. Initialize Terraform
```bash
terraform init
```

### 2. Review Plan
```bash
terraform plan
```

### 3. Deploy Infrastructure
```bash
terraform apply
```
1236
### 4. Note the Elastic IP
```bash
terraform output nat_gateway_eip
```
**Provide this IP to Altair for whitelisting.**

### 5. Create WorkSpaces (Manual)
1. AWS Console → WorkSpaces
2. Launch WorkSpaces
3. Use the subnet IDs from: `terraform output workspaces_subnet_ids`
4. Select both private subnets
5. Choose cheapest bundle (Value Windows)
6. Deploy

### 6. Test Egress IP
From inside the WorkSpace:
```powershell
# PowerShell
(Invoke-WebRequest -Uri "https://api.ipify.org").Content
```

This should return the NAT Gateway EIP from step 4.

### 7. Cleanup (Important for cost management!)
```bash
# Delete WorkSpaces from console first
# Then destroy Terraform resources:
terraform destroy
```

## Troubleshooting

### WorkSpaces can't reach internet
- Check route table association (private subnets → NAT Gateway route table)
- Verify NAT Gateway is in "available" state
- Check security group allows outbound traffic

### Different IP showing
- Ensure WorkSpaces are in the private subnets (not public)
- Verify route table has `0.0.0.0/0 → NAT Gateway`