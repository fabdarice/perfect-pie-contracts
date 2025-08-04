#!/bin/bash

# Contract details
CONTRACT_ADDRESS="0xA0CfF887a64CBB93037319f57B896fD7812fA863"
OWNER_ADDRESS="0x0978679F224758c5851Efb3767ED18f480482bd4"

echo "Verifying Perfect Pie Token on BaseScan..."
echo "Contract: $CONTRACT_ADDRESS"
echo "Owner: $OWNER_ADDRESS"

# Load environment for API key
source .env.prod

# Run verification
forge verify-contract $CONTRACT_ADDRESS \
  src/PerfectPieToken.sol:PerfectPie \
  --chain base \
  --constructor-args $(cast abi-encode "constructor(address)" $OWNER_ADDRESS)