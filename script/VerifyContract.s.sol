// SPDX-License-Identifier: MIT
pragma solidity ^0.8.13;

import "forge-std/Script.sol";
import "../src/PerfectPieToken.sol";

contract VerifyContractScript is Script {
    function run() external view {
        // Load contract address from environment or command line
        address contractAddress = vm.envAddress("CONTRACT_ADDRESS");
        require(contractAddress != address(0), "CONTRACT_ADDRESS not set");

        console.log("=== Verifying Perfect Pie Token ===");
        console.log("Contract address:", contractAddress);
        console.log("Chain ID:", block.chainid);

        // Create contract instance
        PerfectPie token = PerfectPie(contractAddress);

        // Verify contract exists
        uint256 codeSize;
        assembly {
            codeSize := extcodesize(contractAddress)
        }
        require(codeSize > 0, "No contract at specified address");
        console.log("[OK] Contract exists (code size:", codeSize, "bytes)");

        // Verify token properties
        console.log("\n=== Token Properties ===");
        console.log("Name:", token.name());
        console.log("Symbol:", token.symbol());
        console.log("Decimals:", token.decimals());
        console.log("Total Supply:", token.totalSupply() / 1e18, "PIE");
        console.log("Contract Balance:", token.getContractBalance() / 1e18, "PIE");
        console.log("Owner:", token.owner());

        // Verify expected values
        require(
            keccak256(bytes(token.name())) == keccak256(bytes("Perfect Pie")),
            "Unexpected token name"
        );
        require(
            keccak256(bytes(token.symbol())) == keccak256(bytes("PIE")),
            "Unexpected token symbol"
        );
        require(token.decimals() == 18, "Unexpected decimals");
        require(token.totalSupply() == 10e9 * 10 ** 18, "Unexpected total supply");

        console.log("\n[SUCCESS] All verifications passed!");

        // Generate verification command
        string memory network = block.chainid == 8453 ? "base" : "base-sepolia";
        console.log("\n=== Manual Verification Command ===");
        console.log("Run this command to verify on BaseScan:");
        console.log(
            string.concat(
                "forge verify-contract ",
                vm.toString(contractAddress),
                " src/PerfectPieToken.sol:PerfectPie --chain ",
                network,
                " --constructor-args ",
                vm.toString(abi.encode(token.owner()))
            )
        );
    }
}