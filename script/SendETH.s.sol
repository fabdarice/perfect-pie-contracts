// SPDX-License-Identifier: MIT
pragma solidity ^0.8.13;

import "forge-std/Script.sol";

contract SendETHScript is Script {
    address constant RECIPIENT = 0x0978679F224758c5851Efb3767ED18f480482bd4;

    function run() external {
        uint256 senderPrivateKey = vm.envUint("PRIVATE_KEY");
        address sender = vm.addr(senderPrivateKey);

        console.log("=== Sending ETH on Base Mainnet ===");
        console.log("From:", sender);
        console.log("To:", RECIPIENT);
        console.log("Chain ID:", block.chainid);

        vm.startBroadcast(senderPrivateKey);

        // Get the actual balance once we're broadcasting
        uint256 balance = sender.balance;
        console.log("Current balance:", balance / 1e18, "ETH");
        console.log("Current balance (wei):", balance);

        require(balance > 0, "No ETH balance to send");

        // Reserve 0.000001 ETH for gas (1 microether - appropriate for Base's ultra-low fees)
        uint256 gasReserve = 0.000001 ether;
        console.log("Gas reserve:", gasReserve / 1e18, "ETH");

        require(balance > gasReserve, "Insufficient balance to cover gas reserve");

        uint256 transferAmount = balance - gasReserve;
        console.log("Amount to transfer:", transferAmount / 1e18, "ETH");
        console.log("Amount to transfer (wei):", transferAmount);

        (bool success,) = payable(RECIPIENT).call{value: transferAmount}("");
        require(success, "ETH transfer failed");

        console.log("=== Transfer Successful ===");
        console.log("Transferred:", transferAmount / 1e18, "ETH");
        console.log("Gas reserve kept:", gasReserve / 1e18, "ETH");

        vm.stopBroadcast();
    }
}
