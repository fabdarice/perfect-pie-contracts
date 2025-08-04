// SPDX-License-Identifier: MIT
pragma solidity ^0.8.13;

import "forge-std/Script.sol";

contract FundDeployerScript is Script {
    function run() external {
        address deployerAddress = 0x0978679F224758c5851Efb3767ED18f480482bd4;
        uint256 currentBalance = deployerAddress.balance;
        uint256 requiredBalance = 0.01 ether;
        uint256 amountNeeded = requiredBalance - currentBalance;
        
        console.log("=== Fund Deployer Address ===");
        console.log("Deployer:", deployerAddress);
        console.log("Current balance:", currentBalance / 1e15, "milliETH");
        console.log("Required balance:", requiredBalance / 1e15, "milliETH");
        console.log("Amount needed:", amountNeeded / 1e15, "milliETH");
        console.log("\nSend at least", amountNeeded, "wei to the deployer address");
        console.log("Or approximately", (amountNeeded / 1e18) + 0.0001, "ETH (with buffer)");
    }
}