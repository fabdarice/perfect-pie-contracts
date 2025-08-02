# Perfect Pie Token 🥧

A signature-based ERC20 token contract deployed on Base blockchain with advanced claiming mechanisms and burn functionality.

## 📋 Overview

**Perfect Pie (PIE)** is an ERC20 token with the following features:
- **Total Supply:** 10 billion PIE tokens
- **Signature-Based Claims:** Users can claim tokens using owner-signed messages
- **Burn Functionality:** Token holders can burn their tokens
- **Replay Protection:** Prevents signature reuse attacks
- **Base Optimized:** Built for Base mainnet and Sepolia testnet

## 🏗 Contract Details

- **Contract Name:** `PerfectPie`
- **Token Name:** "Perfect Pie"  
- **Symbol:** PIE
- **Decimals:** 18
- **Max Supply:** 10,000,000,000 PIE
- **Architecture:** All tokens minted to contract, distributed via signature-based claims

## 🚀 Quick Start

### Prerequisites
- [Foundry](https://book.getfoundry.sh/getting-started/installation)
- Base Sepolia ETH for testnet deployment
- Base ETH for mainnet deployment

### Installation
```bash
git clone https://github.com/[username]/perfect-pie-token
cd perfect-pie-token
forge install
```

### Environment Setup
```bash
cp .env.example .env
# Edit .env with your private key and API keys
```

## 🔧 Usage

### Build
```bash
forge build
```

### Test
```bash
forge test -vv
```

### Deploy to Base Sepolia (Testnet)
```bash
forge script script/Deploy.s.sol --rpc-url base_sepolia --broadcast --verify
```

### Deploy to Base Mainnet
```bash
forge script script/Deploy.s.sol --rpc-url base_mainnet --broadcast --verify
```

### Check Balance
```bash
forge script script/CheckBalance.s.sol --rpc-url base_sepolia
```

### Send ETH
```bash
forge script script/SendETH.s.sol --rpc-url base_mainnet --broadcast
```

## 🎯 Core Functions

### `claim(address receiver, uint256 amount, uint256 epoch, bytes memory signature)`
Allows users to claim tokens using an owner-signed message:
- Verifies ECDSA signature from contract owner
- Prevents signature replay attacks
- Transfers tokens from contract to receiver

### `burn(uint256 amount)`
Allows token holders to permanently destroy their tokens:
- Reduces total supply
- Burns tokens from caller's balance

### `getContractBalance()`
Returns the number of unclaimed tokens remaining in the contract.

## 🔐 Security Features

- **OpenZeppelin Contracts:** Built on battle-tested libraries
- **Signature Verification:** ECDSA signature validation with proper message hashing
- **Replay Protection:** Used signatures are tracked and prevented from reuse
- **Access Control:** Owner-based permissions using OpenZeppelin's Ownable
- **Input Validation:** Comprehensive checks for addresses, amounts, and balances

## 🧪 Testing

The project includes comprehensive tests covering:
- ✅ Contract deployment and initialization
- ✅ Valid signature-based claims
- ✅ Invalid signature rejection
- ✅ Signature replay protection
- ✅ Edge cases and error conditions
- ✅ Burn functionality
- ✅ Multiple claims with different epochs

Run tests:
```bash
forge test -vv
```

## 📜 Smart Contract

### Key Components
- **ERC20:** Standard token functionality
- **ERC20Burnable:** Token burning capability
- **Ownable:** Access control for administrative functions
- **ECDSA:** Cryptographic signature verification
- **MessageHashUtils:** Proper message hashing for signatures

### Gas Optimization
- Optimized for Base's low gas costs
- Conservative gas reserves (0.000001 ETH)
- Efficient signature verification

## 🌐 Networks

### Base Sepolia (Testnet)
- **Chain ID:** 84532
- **RPC:** https://sepolia.base.org
- **Faucet:** [Base Sepolia Faucet](https://coinbase.com/faucets/base-ethereum-sepolia-faucet)

### Base Mainnet
- **Chain ID:** 8453
- **RPC:** https://mainnet.base.org
- **Explorer:** [BaseScan](https://basescan.org)

## 📝 License

This project is licensed under the MIT License.

## 🤝 Contributing

Contributions are welcome! Please feel free to submit a Pull Request.

## ⚠️ Disclaimer

This contract is provided as-is. Please conduct thorough testing and audits before using in production.
