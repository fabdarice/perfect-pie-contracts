# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Project Overview

Perfect Pie Token is a signature-based ERC20 token contract built for deployment on Base blockchain. It features:
- 10 billion PIE token supply
- Signature-based claiming mechanism with replay protection
- Burn functionality
- Owner-controlled signature generation

## Development Commands

### Build & Test
```bash
# Build contracts
forge build

# Run tests with verbose output
forge test -vv

# Run specific test
forge test --match-test testClaim -vv

# Gas report
forge test --gas-report
```

### Deployment

#### Testnet (Base Sepolia)
```bash
# Deploy to testnet
forge script script/Deploy.s.sol --rpc-url base_sepolia --broadcast --verify

# Check deployment
forge script script/CheckBalance.s.sol --rpc-url base_sepolia
```

#### Mainnet (Base)
```bash
# Dry run (simulation only)
forge script script/DeployMainnet.s.sol --rpc-url base_mainnet

# Deploy with safety checks and confirmation
REQUIRE_CONFIRMATION=true forge script script/DeployMainnetSafe.s.sol \
  --rpc-url base_mainnet \
  --broadcast \
  --verify \
  --gas-estimate-multiplier 120 \
  --interactives 1 \
  -vvvv

# Resume failed deployment
forge script script/DeployMainnet.s.sol --rpc-url base_mainnet --resume
```

### Verification
```bash
# Verify deployed contract
CONTRACT_ADDRESS=0x... forge script script/VerifyContract.s.sol --rpc-url base_mainnet

# Manual verification on BaseScan
forge verify-contract <ADDRESS> src/PerfectPieToken.sol:PerfectPie --chain base
```

### Utilities
```bash
# View deployment guide
forge script script/DeploymentGuide.s.sol

# Send ETH to address
forge script script/SendETH.s.sol --rpc-url base_mainnet --broadcast
```

## Architecture

### Contract Structure
```
src/
└── PerfectPieToken.sol      # Main ERC20 token contract
    ├── ERC20               # Standard token functionality
    ├── ERC20Burnable       # Burn capability
    ├── Ownable             # Owner management
    └── ECDSA/MessageHash   # Signature verification

script/
├── Deploy.s.sol             # Basic deployment script
├── DeployMainnet.s.sol      # Mainnet deployment with checks
├── DeployMainnetSafe.s.sol  # Safe deployment with confirmations
├── VerifyContract.s.sol     # Post-deployment verification
├── DeploymentGuide.s.sol    # Interactive deployment guide
├── CheckBalance.s.sol       # Check contract/account balances
└── SendETH.s.sol           # Send ETH utility
```

### Key Mechanisms

1. **Token Distribution**: All 10B tokens minted to contract on deployment
2. **Claiming Process**: 
   - Owner signs message with (receiver, amount, epoch)
   - User calls claim() with signature
   - Contract verifies signature and transfers tokens
3. **Security Features**:
   - Signature replay protection via signature hash tracking
   - Epoch parameter for time-based claims
   - Owner-only signature generation

### Deployment Flow

1. **Pre-deployment**:
   - Set PRIVATE_KEY and ETHERSCAN_API_KEY in .env
   - Ensure deployer has sufficient ETH (0.05+ recommended)
   - Review gas prices on BaseScan

2. **Deployment**:
   - Use DeployMainnetSafe.s.sol for production
   - Script performs pre-flight checks
   - Simulates deployment before broadcasting
   - Saves deployment artifacts

3. **Post-deployment**:
   - Verify contract on BaseScan
   - Test signature generation
   - Document deployed address

## Testing Approach

Tests cover:
- Contract initialization
- Valid signature claims
- Invalid signature rejection  
- Replay protection
- Burn functionality
- Edge cases and error conditions

Run with `forge test -vv` for detailed output.

## Environment Configuration

Required in `.env`:
- `PRIVATE_KEY`: Deployer private key
- `ETHERSCAN_API_KEY`: For verification

Optional:
- `OWNER_ADDRESS`: Contract owner (defaults to deployer)
- `REQUIRE_CONFIRMATION`: Prompt before mainnet deploy
- `CONTRACT_ADDRESS`: For verification scripts

## Security Considerations

1. **Private Key Management**: Never commit private keys
2. **Owner Address**: Double-check before deployment
3. **Signature Generation**: Keep signing key secure
4. **Gas Settings**: Use multiplier for mainnet deployments
5. **Verification**: Always verify contract source immediately

## Base Network Details

**Mainnet**:
- Chain ID: 8453
- RPC: https://mainnet.base.org
- Explorer: https://basescan.org

**Sepolia Testnet**:
- Chain ID: 84532  
- RPC: https://sepolia.base.org
- Explorer: https://sepolia.basescan.org