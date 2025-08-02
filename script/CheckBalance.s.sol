// SPDX-License-Identifier: MIT
pragma solidity ^0.8.13;

import "forge-std/Script.sol";

contract CheckBalanceScript is Script {
    function run() external view {
        uint256 privateKey = vm.envUint("PRIVATE_KEY");
        address wallet = vm.addr(privateKey);
        
        uint256 balance = wallet.balance;
        
        console.log("=== Balance Check ===");
        console.log("Address:", wallet);
        console.log("Chain ID:", block.chainid);
        
        if (block.chainid == 84532) {
            console.log("Network: Base Sepolia");
        } else if (block.chainid == 8453) {
            console.log("Network: Base Mainnet");
        } else {
            console.log("Network: Unknown");
        }
        
        console.log("Raw balance (wei):", balance);
        console.log("Balance (ETH):", balance / 1e18);
        
        // Show with high precision (18 decimals)
        console.log("Balance (precise):", balance / 1e10, "/ 10^8 ETH");
        
        // Show in different units
        console.log("Balance in Gwei:", balance / 1e9);
        console.log("Balance in Wei:", balance);
        
        // Deployment cost estimates
        uint256 deployGasEstimate = 2000000; // ~2M gas for contract deployment
        uint256 baseGasPrice = 0.001 gwei; // Base's typical gas price
        uint256 estimatedCost = deployGasEstimate * baseGasPrice;
        
        console.log("=== Deployment Cost Estimate ===");
        console.log("Estimated gas needed:", deployGasEstimate);
        console.log("Base gas price (~):", baseGasPrice / 1e9, "gwei");
        console.log("Estimated cost (wei):", estimatedCost);
        console.log("Estimated cost (ETH):", estimatedCost / 1e18);
        
        if (balance >= estimatedCost) {
            console.log("✅ Sufficient balance for deployment");
        } else {
            console.log("❌ Insufficient balance for deployment");
            console.log("Need additional:", (estimatedCost - balance) / 1e18, "ETH");
        }
    }
}