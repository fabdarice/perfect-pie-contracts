// SPDX-License-Identifier: MIT
pragma solidity ^0.8.13;

import "forge-std/Script.sol";
import "../src/PerfectPieToken.sol";

contract DeployScript is Script {
    function run() external {
        uint256 deployerPrivateKey = vm.envUint("PRIVATE_KEY");
        address deployer = vm.addr(deployerPrivateKey);

        string memory network = block.chainid == 8453
            ? "Base Mainnet"
            : "Base Sepolia";
        console.log("=== Deploying Perfect Pie Token to", network, "===");
        console.log("Deployer address:", deployer);
        console.log("Chain ID:", block.chainid);

        // Get deployer balance to ensure sufficient funds
        uint256 balance = deployer.balance;
        console.log("Deployer ETH balance:", balance, "Wei");
        require(
            balance > 0.01 ether,
            "Insufficient ETH balance for deployment"
        );

        vm.startBroadcast(deployerPrivateKey);

        PerfectPie token = new PerfectPie(deployer);

        vm.stopBroadcast();

        console.log("=== Deployment Successful ===");
        console.log("PerfectPie deployed at:", address(token));
        console.log("Token name:", token.name());
        console.log("Token symbol:", token.symbol());
        console.log("Decimals:", token.decimals());
        console.log("Total supply:", token.totalSupply() / 1e18, "PIE");
        console.log(
            "Contract balance:",
            token.getContractBalance() / 1e18,
            "PIE"
        );
        console.log("Owner:", token.owner());

        console.log("=== Next Steps ===");
        console.log("1. Verify contract on BaseScan:");
        string memory chainFlag = block.chainid == 8453
            ? "--chain base"
            : "--chain base-sepolia";
        console.log(
            "   forge verify-contract",
            address(token),
            "src/PerfectPieToken.sol:PerfectPie",
            chainFlag
        );
        console.log("2. Contract is ready for signature-based token claims!");
    }
}
