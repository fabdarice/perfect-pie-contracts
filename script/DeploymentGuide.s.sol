// SPDX-License-Identifier: MIT
pragma solidity ^0.8.13;

import "forge-std/Script.sol";

contract DeploymentGuideScript is Script {
    function run() external view {
        console.log("\n====================================");
        console.log("Perfect Pie Token Deployment Guide");
        console.log("====================================\n");

        // Check current network
        string memory network = getNetworkName();
        console.log("Current network:", network);
        console.log("Chain ID:", block.chainid);
        
        if (block.chainid != 8453 && block.chainid != 84532) {
            console.log("\n[WARNING] Not on Base mainnet or testnet!");
        }

        console.log("\n=== Pre-deployment Checklist ===");
        console.log("1. [ ] Environment variables set:");
        console.log("   - PRIVATE_KEY: Your deployer private key");
        console.log("   - ETHERSCAN_API_KEY: For contract verification");
        console.log("   - OWNER_ADDRESS: (Optional) Contract owner if different from deployer");
        console.log("2. [ ] Sufficient ETH balance (min 0.05 ETH recommended)");
        console.log("3. [ ] Gas prices checked on BaseScan");
        console.log("4. [ ] Deployment script reviewed");

        console.log("\n=== Deployment Commands ===");
        
        console.log("\n1. Dry run (simulation only):");
        console.log("   forge script script/DeployMainnet.s.sol --rpc-url base_mainnet");
        
        console.log("\n2. Deploy with confirmation prompt:");
        console.log("   REQUIRE_CONFIRMATION=true forge script script/DeployMainnetSafe.s.sol \\");
        console.log("     --rpc-url base_mainnet \\");
        console.log("     --broadcast \\");
        console.log("     --verify \\");
        console.log("     --gas-estimate-multiplier 120 \\");
        console.log("     --interactives 1 \\");
        console.log("     -vvvv");
        
        console.log("\n3. Deploy without confirmation:");
        console.log("   forge script script/DeployMainnet.s.sol \\");
        console.log("     --rpc-url base_mainnet \\");
        console.log("     --broadcast \\");
        console.log("     --verify \\");
        console.log("     --gas-estimate-multiplier 120 \\");
        console.log("     -vvvv");

        console.log("\n4. Resume failed deployment:");
        console.log("   forge script script/DeployMainnet.s.sol \\");
        console.log("     --rpc-url base_mainnet \\");
        console.log("     --resume");

        console.log("\n=== Post-deployment Commands ===");
        
        console.log("\n1. Verify deployed contract:");
        console.log("   CONTRACT_ADDRESS=0x... forge script script/VerifyContract.s.sol --rpc-url base_mainnet");
        
        console.log("\n2. Manual verification on BaseScan:");
        console.log("   forge verify-contract <CONTRACT_ADDRESS> \\");
        console.log("     src/PerfectPieToken.sol:PerfectPie \\");
        console.log("     --chain base \\");
        console.log("     --constructor-args $(cast abi-encode \"constructor(address)\" <OWNER_ADDRESS>)");

        console.log("\n=== Gas Estimation ===");
        uint256 estimatedGas = 1_500_000; // Approximate gas for token deployment
        uint256[] memory gasPrices = new uint256[](3);
        gasPrices[0] = 0.1 gwei; // Low
        gasPrices[1] = 1 gwei;   // Average
        gasPrices[2] = 5 gwei;   // High

        console.log("\nEstimated deployment costs:");
        for (uint i = 0; i < gasPrices.length; i++) {
            uint256 cost = estimatedGas * gasPrices[i];
            string memory label = i == 0 ? "Low" : i == 1 ? "Average" : "High";
            console.log(
                string.concat(
                    "- ",
                    label,
                    " (",
                    vm.toString(gasPrices[i] / 1e9),
                    " gwei): ",
                    vm.toString(cost / 1e18),
                    ".",
                    vm.toString((cost % 1e18) / 1e14),
                    " ETH"
                )
            );
        }

        console.log("\n=== Security Reminders ===");
        console.log("[WARNING] NEVER commit your private key");
        console.log("[WARNING] Double-check the owner address");
        console.log("[WARNING] Verify contract source code immediately after deployment");
        console.log("[WARNING] Test signature generation before announcing deployment");

        console.log("\n=== Additional Resources ===");
        console.log("- BaseScan: https://basescan.org");
        console.log("- Base Documentation: https://docs.base.org");
        console.log("- Foundry Book: https://book.getfoundry.sh");
        console.log("\n");
    }

    function getNetworkName() internal view returns (string memory) {
        if (block.chainid == 1) return "Ethereum Mainnet";
        if (block.chainid == 8453) return "Base Mainnet";
        if (block.chainid == 84532) return "Base Sepolia";
        if (block.chainid == 11155111) return "Sepolia";
        if (block.chainid == 31337) return "Local Anvil";
        return string.concat("Unknown (", vm.toString(block.chainid), ")");
    }
}