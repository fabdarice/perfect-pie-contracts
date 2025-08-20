# PerfectPie V2 - Upgradeable Token with Admin Burn

## Overview

PerfectPieV2 is an upgradeable version of the PerfectPie token that implements:
- **UUPS Proxy Pattern**: Allows contract upgrades while preserving state
- **Admin Burn Functionality**: Owner can burn tokens from any account
- **All Original Features**: Signature-based claiming, standard burn, 10B supply

## Key Features

### 1. Upgradeability
- Uses OpenZeppelin's UUPS (Universal Upgradeable Proxy Standard)
- Only the owner can authorize upgrades
- State is preserved across upgrades
- Gas-efficient proxy pattern

### 2. Admin Burn Function
```solidity
function adminBurn(address from, uint256 amount) external onlyOwner
```
- Allows the contract owner to burn tokens from any address
- Emits `AdminBurn` event for transparency
- Includes safety checks for zero address and balance

### 3. Original Features Retained
- 10 billion PIE token supply
- Signature-based claiming with replay protection
- User-initiated burn functionality
- Owner-controlled distribution

## Deployment

### Deploy Upgradeable Contract
```bash
# Deploy to testnet
forge script script/DeployUpgradeable.s.sol --rpc-url base_sepolia --broadcast --verify

# Deploy to mainnet
forge script script/DeployUpgradeable.s.sol --rpc-url base_mainnet --broadcast --verify
```

The deployment will:
1. Deploy the implementation contract
2. Deploy the proxy contract
3. Initialize the proxy with the implementation
4. Save deployment addresses to `deployments/[chainId]-deployment.json`

### Important Addresses
After deployment, you'll have two addresses:
- **Proxy Address**: This is the main contract address users interact with
- **Implementation Address**: The logic contract (users don't interact with this directly)

## Upgrading the Contract

To upgrade the contract in the future:

1. Set the proxy address in your environment:
```bash
export PROXY_ADDRESS=0x... # Your deployed proxy address
```

2. Run the upgrade script:
```bash
forge script script/UpgradeContract.s.sol --rpc-url base_mainnet --broadcast
```

The upgrade will:
1. Deploy a new implementation
2. Upgrade the proxy to point to the new implementation
3. Preserve all token balances and state
4. Save upgrade info to `upgrades/[chainId]-upgrade-[timestamp].json`

## Admin Burn Usage

The admin burn function allows the owner to burn tokens from any account:

```solidity
// Example: Burn 1000 tokens from a specific address
token.adminBurn(addressToBurnFrom, 1000 * 10**18);
```

### Use Cases
- Remove tokens from compromised accounts
- Burn tokens from inactive addresses
- Manage token supply dynamically
- Emergency response to security issues

### Security Considerations
- Only the contract owner can execute admin burns
- All burns are logged with `AdminBurn` events
- Cannot burn from zero address
- Cannot burn more than account balance

## Testing

Run the comprehensive test suite:
```bash
# Run all V2 tests
forge test --match-contract PerfectPieTokenV2Test -vv

# Run specific test
forge test --match-test testAdminBurn -vv
```

Tests cover:
- Initialization and proxy setup
- Admin burn functionality
- Access control
- Upgrade mechanism
- Original features (claiming, burning)
- Edge cases and error conditions

## Migration from V1

If you have an existing non-upgradeable PerfectPie deployment:

1. **Deploy V2**: Deploy the new upgradeable contract
2. **Transfer Remaining Supply**: Move unclaimed tokens from V1 to V2
3. **Update Frontend**: Point your application to the new proxy address
4. **Announce Migration**: Inform users about the new contract address

Note: Already distributed tokens in V1 cannot be automatically migrated. Users would need to interact with a migration contract if you want to swap V1 for V2 tokens.

## Security Notes

### Trust Considerations
- Admin burn introduces centralized control
- Document and communicate this capability clearly to users
- Consider implementing a timelock or multisig for admin functions
- Regular security audits recommended for upgradeable contracts

### Best Practices
- Always test upgrades on testnet first
- Keep implementation contract addresses documented
- Monitor admin burn events
- Implement access control carefully
- Consider adding pause functionality for emergencies

## Gas Costs

Approximate gas costs on Base:
- Deployment: ~3-4M gas (proxy + implementation)
- Admin Burn: ~50-70k gas
- Upgrade: ~100-150k gas
- Claims: ~80-100k gas (same as V1)

## Contract Verification

After deployment, verify both contracts:
```bash
# Verify implementation
forge verify-contract [IMPLEMENTATION_ADDRESS] src/PerfectPieTokenV2.sol:PerfectPieV2 --chain base

# Verify proxy
forge verify-contract [PROXY_ADDRESS] @openzeppelin/contracts/proxy/ERC1967/ERC1967Proxy.sol:ERC1967Proxy --chain base
```

## Support

For issues or questions:
- Review test files for usage examples
- Check deployment artifacts in `deployments/` folder
- Ensure correct environment variables are set
- Test on Sepolia before mainnet deployment