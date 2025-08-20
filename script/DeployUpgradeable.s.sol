// SPDX-License-Identifier: MIT
pragma solidity ^0.8.13;

import "forge-std/Script.sol";
import "../src/PerfectPieTokenV2.sol";
import "@openzeppelin/contracts/proxy/ERC1967/ERC1967Proxy.sol";

contract DeployUpgradeable is Script {
    function run() external {
        uint256 deployerPrivateKey = vm.envUint("PRIVATE_KEY");
        address deployer = vm.addr(deployerPrivateKey);

        // Use OWNER_ADDRESS from env if set, otherwise use deployer
        address owner = vm.envOr("OWNER_ADDRESS", deployer);

        console.log("Deploying PerfectPieV2 Upgradeable Contract");
        console.log("Deployer:", deployer);
        console.log("Owner:", owner);
        console.log("Chain ID:", block.chainid);

        vm.startBroadcast(deployerPrivateKey);

        // Deploy implementation
        PerfectPieV2 implementation = new PerfectPieV2();
        console.log("Implementation deployed at:", address(implementation));

        // Deploy proxy
        bytes memory initData = abi.encodeWithSelector(PerfectPieV2.initialize.selector, owner);

        ERC1967Proxy proxy = new ERC1967Proxy(address(implementation), initData);
        console.log("Proxy deployed at:", address(proxy));

        // Verify the deployment
        PerfectPieV2 token = PerfectPieV2(address(proxy));
        console.log("Token name:", token.name());
        console.log("Token symbol:", token.symbol());
        console.log("Total supply:", token.totalSupply());
        console.log("Contract balance:", token.getContractBalance());
        console.log("Owner:", token.owner());

        vm.stopBroadcast();

        // Save deployment info
        string memory deploymentInfo = string(
            abi.encodePacked(
                "{\n",
                '  "implementation": "',
                vm.toString(address(implementation)),
                '",\n',
                '  "proxy": "',
                vm.toString(address(proxy)),
                '",\n',
                '  "owner": "',
                vm.toString(owner),
                '",\n',
                '  "chainId": ',
                vm.toString(block.chainid),
                ",\n",
                '  "deployer": "',
                vm.toString(deployer),
                '"\n',
                "}"
            )
        );

        string memory filename =
            string(abi.encodePacked("deployments/", vm.toString(block.chainid), "-deployment.json"));

        vm.writeFile(filename, deploymentInfo);
        console.log("Deployment info saved to:", filename);
    }
}
