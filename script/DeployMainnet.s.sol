// SPDX-License-Identifier: MIT
pragma solidity ^0.8.13;

import "forge-std/Script.sol";
import "../src/PerfectPieToken.sol";

contract DeployMainnetScript is Script {
    function run() external returns (PerfectPie) {
        // Load deployer private key
        uint256 deployerPrivateKey = vm.envUint("PRIVATE_KEY");
        address deployer = vm.addr(deployerPrivateKey);

        console.log("=== Perfect Pie Token Mainnet Deployment ===");
        console.log("Deployer address:", deployer);
        console.log("Chain ID:", block.chainid);
        console.log("Block number:", block.number);

        // Validate we're on Base mainnet
        require(block.chainid == 8453, "Not on Base mainnet!");

        // Check deployer balance
        uint256 balance = deployer.balance;
        console.log("Deployer ETH balance:", balance / 1e18, "ETH");
        console.log("Deployer ETH balance (Wei):", balance);
        
        // Require minimum balance for deployment and gas
        require(
            balance >= 0.05 ether,
            "Insufficient ETH balance - need at least 0.05 ETH for deployment"
        );

        // Estimate gas price
        uint256 gasPrice = tx.gasprice;
        if (gasPrice == 0) {
            gasPrice = 1 gwei; // Fallback gas price
        }
        console.log("Current gas price:", gasPrice / 1e9, "gwei");

        // Start deployment
        vm.startBroadcast(deployerPrivateKey);

        // Deploy Perfect Pie Token
        PerfectPie token = new PerfectPie(deployer);

        vm.stopBroadcast();

        // Post-deployment verification
        console.log("\n=== Deployment Successful ===");
        console.log("PerfectPie deployed at:", address(token));
        console.log("Token name:", token.name());
        console.log("Token symbol:", token.symbol());
        console.log("Decimals:", token.decimals());
        console.log("Total supply:", token.totalSupply() / 1e18, "PIE");
        console.log("Contract balance:", token.getContractBalance() / 1e18, "PIE");
        console.log("Owner:", token.owner());

        // Verify deployment
        require(token.owner() == deployer, "Owner not set correctly");
        require(token.totalSupply() == 10e9 * 10 ** 18, "Total supply incorrect");
        require(token.getContractBalance() == token.totalSupply(), "Contract balance incorrect");

        console.log("\n=== Next Steps ===");
        console.log("1. Save the contract address:", address(token));
        console.log("2. Verify contract on BaseScan:");
        console.log("   forge verify-contract", address(token), "src/PerfectPieToken.sol:PerfectPie --chain base");
        console.log("3. Update project documentation with deployed address");
        console.log("4. Configure signature generation for token claims");
        
        return token;
    }
}