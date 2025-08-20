// SPDX-License-Identifier: MIT
pragma solidity ^0.8.13;

import "forge-std/Script.sol";
import "../src/PerfectPieToken.sol";

contract DeployMainnetSafeScript is Script {
    // Configuration
    uint256 constant MIN_BALANCE = 0.01 ether; // Minimum deployer balance for Base
    uint256 constant GAS_PRICE_MAX = 100 gwei; // Maximum acceptable gas price
    uint256 constant GAS_ESTIMATE_MULTIPLIER = 120; // 20% buffer for gas estimation

    // Expected deployment parameters
    string constant EXPECTED_NAME = "Perfect Pie";
    string constant EXPECTED_SYMBOL = "PIE";
    uint8 constant EXPECTED_DECIMALS = 18;
    uint256 constant EXPECTED_SUPPLY = 10e9 * 10 ** 18;

    function run() external returns (PerfectPie) {
        // Load configuration
        uint256 deployerPrivateKey = vm.envUint("PRIVATE_KEY");
        address deployer = vm.addr(deployerPrivateKey);

        // Optional: Load owner address (defaults to deployer if not set)
        address owner = deployer;
        try vm.envAddress("OWNER_ADDRESS") returns (address envOwner) {
            if (envOwner != address(0)) {
                owner = envOwner;
            }
        } catch {
            console.log("OWNER_ADDRESS not set, using deployer as owner");
        }

        console.log("=================================");
        console.log("Perfect Pie Token Mainnet Deployment");
        console.log("=================================");
        console.log("Deployer:", deployer);
        console.log("Owner:", owner);
        console.log("Timestamp:", block.timestamp);
        console.log("Block:", block.number);

        // Pre-deployment checks
        preDeploymentChecks(deployer);

        // Simulate deployment first
        console.log("\n=== Simulating Deployment ===");
        vm.startPrank(deployer);
        PerfectPie simulatedToken = new PerfectPie(owner);
        vm.stopPrank();

        console.log("Simulation successful!");
        console.log("Estimated contract address:", address(simulatedToken));

        // Ask for confirmation
        bool requireConfirmation = false;
        try vm.envBool("REQUIRE_CONFIRMATION") returns (bool value) {
            requireConfirmation = value;
        } catch {
            // Default to false if not set
        }

        if (requireConfirmation) {
            console.log("\n[WARNING] Ready to deploy to Base mainnet!");
            console.log("Contract will be owned by:", owner);
            console.log("Press any key to continue or Ctrl+C to abort...");
            vm.prompt("confirm");
        }

        // Actual deployment
        console.log("\n=== Starting Deployment ===");
        vm.startBroadcast(deployerPrivateKey);

        PerfectPie token = new PerfectPie(owner);

        vm.stopBroadcast();

        // Post-deployment verification
        postDeploymentVerification(token, owner);

        // Log deployment information
        logDeploymentInfo(token);

        // Save deployment artifact
        saveDeploymentArtifact(address(token), owner, deployer);

        return token;
    }

    function preDeploymentChecks(address deployer) internal view {
        console.log("\n=== Pre-deployment Checks ===");

        // Check chain ID
        require(block.chainid == 8453, "Not on Base mainnet! Expected chain ID: 8453");
        console.log("[OK] Chain ID verified: Base mainnet");

        // Check deployer balance
        uint256 balance = deployer.balance;
        require(balance >= MIN_BALANCE, "Insufficient ETH balance for deployment");
        console.log("[OK] Deployer balance:", balance / 1e18, "ETH");

        // Check gas price
        uint256 gasPrice = tx.gasprice;
        if (gasPrice == 0) {
            gasPrice = block.basefee;
        }
        require(gasPrice <= GAS_PRICE_MAX, "Gas price too high!");
        console.log("[OK] Gas price:", gasPrice / 1e9, "gwei");
        console.log("     Max allowed:", GAS_PRICE_MAX / 1e9, "gwei");

        // Check if contract already exists at expected address
        uint256 nonce = vm.getNonce(deployer);
        address expectedAddress = computeCreateAddress(deployer, nonce);
        uint256 codeSize;
        assembly {
            codeSize := extcodesize(expectedAddress)
        }
        require(codeSize == 0, "Contract already exists at expected address!");
        console.log("[OK] Expected deployment address is empty");
        console.log("  Expected address:", expectedAddress);
    }

    function postDeploymentVerification(PerfectPie token, address expectedOwner) internal view {
        console.log("\n=== Post-deployment Verification ===");

        // Verify basic token properties
        require(keccak256(bytes(token.name())) == keccak256(bytes(EXPECTED_NAME)), "Token name mismatch");
        console.log("[OK] Token name:", token.name());

        require(keccak256(bytes(token.symbol())) == keccak256(bytes(EXPECTED_SYMBOL)), "Token symbol mismatch");
        console.log("[OK] Token symbol:", token.symbol());

        require(token.decimals() == EXPECTED_DECIMALS, "Token decimals mismatch");
        console.log("[OK] Token decimals:", token.decimals());

        require(token.totalSupply() == EXPECTED_SUPPLY, "Total supply mismatch");
        console.log("[OK] Total supply:", token.totalSupply() / 1e18, "PIE");

        // Verify ownership
        require(token.owner() == expectedOwner, "Owner not set correctly");
        console.log("[OK] Contract owner:", token.owner());

        // Verify contract balance
        require(token.getContractBalance() == token.totalSupply(), "Contract balance doesn't match total supply");
        console.log("[OK] Contract balance:", token.getContractBalance() / 1e18, "PIE");

        // Verify contract code
        address tokenAddress = address(token);
        uint256 codeSize;
        assembly {
            codeSize := extcodesize(tokenAddress)
        }
        require(codeSize > 0, "No code at token address");
        console.log("[OK] Contract code size:", codeSize, "bytes");
    }

    function logDeploymentInfo(PerfectPie token) internal view {
        console.log("\n=================================");
        console.log("DEPLOYMENT SUCCESSFUL!");
        console.log("=================================");
        console.log("Contract Address:", address(token));
        console.log("Block Number:", block.number);
        console.log("Transaction will be included in block:", block.number + 1);
        console.log("\n=== Contract Details ===");
        console.log("Name:", token.name());
        console.log("Symbol:", token.symbol());
        console.log("Decimals:", token.decimals());
        console.log("Total Supply:", token.totalSupply() / 1e18, "PIE");
        console.log("Owner:", token.owner());
    }

    function saveDeploymentArtifact(address tokenAddress, address owner, address deployer) internal {
        string memory artifactPath = string.concat("deployments/", vm.toString(block.chainid), "/PerfectPie.json");

        string memory artifact = string.concat(
            '{"address":"',
            vm.toString(tokenAddress),
            '","owner":"',
            vm.toString(owner),
            '","deployer":"',
            vm.toString(deployer),
            '","blockNumber":',
            vm.toString(block.number),
            ',"timestamp":',
            vm.toString(block.timestamp),
            ',"chainId":',
            vm.toString(block.chainid),
            "}"
        );

        vm.writeFile(artifactPath, artifact);
        console.log("\n[OK] Deployment artifact saved to:", artifactPath);
    }
}
