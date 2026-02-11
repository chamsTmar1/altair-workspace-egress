#!/bin/bash
# Test script to verify egress IP

set -e

echo "========================================="
echo "Testing WorkSpace Egress IP"
echo "========================================="

# Get expected NAT EIP
cd "$(dirname "$0")/.."
EXPECTED_IP=$(terraform output -raw nat_gateway_eip 2>/dev/null || echo "UNKNOWN")

echo "Expected NAT Gateway IP: $EXPECTED_IP"
echo ""
echo "Testing actual egress IP..."

# Test actual egress
ACTUAL_IP=$(curl -s https://api.ipify.org)

echo "Actual egress IP: $ACTUAL_IP"
echo ""

if [ "$ACTUAL_IP" == "$EXPECTED_IP" ]; then
    echo "SUCCESS: Egress IP matches NAT Gateway EIP"
    exit 0
else
    echo "FAILURE: Egress IP does NOT match NAT Gateway EIP"
    echo "Expected: $EXPECTED_IP"
    echo "Got:      $ACTUAL_IP"
    exit 1
fi