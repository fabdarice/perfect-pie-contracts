#!/bin/bash
source .env.prod

echo "Deploying Perfect Pie Token to Base mainnet..."
echo "Using simple deployment script..."

forge script script/Deploy.s.sol \
  --rpc-url https://mainnet.base.org \
  --private-key $PRIVATE_KEY \
  --broadcast \
  --verify \
  --etherscan-api-key $ETHERSCAN_API_KEY \
  -vvvv