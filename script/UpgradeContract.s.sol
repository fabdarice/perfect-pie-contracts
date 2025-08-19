// SPDX-License-Identifier: MIT
pragma solidity ^0.8.13;

import "forge-std/Script.sol";
import "../src/PerfectPieTokenV2.sol";
import "@openzeppelin/contracts/proxy/ERC1967/ERC1967Proxy.sol";

contract UpgradeContract is Script {
    function run() external {
        uint256 deployerPrivateKey = vm.envUint("PRIVATE_KEY");
        address deployer = vm.addr(deployerPrivateKey);
        
        // Get proxy address from environment
        address proxyAddress = vm.envAddress("PROXY_ADDRESS");
        
        console.log("Upgrading PerfectPie Contract");
        console.log("Deployer:", deployer);
        console.log("Proxy Address:", proxyAddress);
        console.log("Chain ID:", block.chainid);
        
        vm.startBroadcast(deployerPrivateKey);
        
        // Deploy new implementation
        PerfectPieV2 newImplementation = new PerfectPieV2();
        console.log("New implementation deployed at:", address(newImplementation));
        
        // Upgrade proxy to new implementation
        PerfectPieV2 token = PerfectPieV2(proxyAddress);
        token.upgradeToAndCall(address(newImplementation), "");
        
        console.log("Proxy upgraded successfully");
        
        // Verify the upgrade
        console.log("Token name:", token.name());
        console.log("Token symbol:", token.symbol());
        console.log("Total supply:", token.totalSupply());
        console.log("Owner:", token.owner());
        
        vm.stopBroadcast();
        
        // Save upgrade info
        string memory upgradeInfo = string(abi.encodePacked(
            "{\n",
            '  "newImplementation": "', vm.toString(address(newImplementation)), '",\n',
            '  "proxy": "', vm.toString(proxyAddress), '",\n',
            '  "chainId": ', vm.toString(block.chainid), ',\n',
            '  "upgrader": "', vm.toString(deployer), '",\n',
            '  "timestamp": ', vm.toString(block.timestamp), '\n',
            "}"
        ));
        
        string memory filename = string(abi.encodePacked(
            "upgrades/",
            vm.toString(block.chainid),
            "-upgrade-",
            vm.toString(block.timestamp),
            ".json"
        ));
        
        vm.writeFile(filename, upgradeInfo);
        console.log("Upgrade info saved to:", filename);
    }
}