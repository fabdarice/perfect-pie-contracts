#!/bin/bash
source .env.prod

echo "Starting Perfect Pie Token deployment to Base mainnet..."
echo "This will broadcast a real transaction!"

forge script script/DeployMainnetSafe.s.sol \
  --rpc-url base_mainnet \
  --broadcast \
  --verify \
  --etherscan-api-key $ETHERSCAN_API_KEY \
  --gas-estimate-multiplier 120 \
  --slow \
  -vvvv