// SPDX-License-Identifier: MIT
pragma solidity ^0.8.13;

import "forge-std/Test.sol";
import "../src/PerfectPieTokenV2.sol";
import "@openzeppelin/contracts/proxy/ERC1967/ERC1967Proxy.sol";

contract PerfectPieTokenV2Test is Test {
    PerfectPieV2 public implementation;
    PerfectPieV2 public token;
    ERC1967Proxy public proxy;
    
    address public owner;
    address public user1;
    address public user2;
    uint256 public ownerPrivateKey;
    
    uint256 constant MAX_SUPPLY = 10e9 * 10 ** 18;
    
    function setUp() public {
        ownerPrivateKey = 1;
        owner = vm.addr(ownerPrivateKey);
        user1 = address(0x1);
        user2 = address(0x2);
        
        // Deploy implementation
        implementation = new PerfectPieV2();
        
        // Deploy proxy with initialization
        bytes memory initData = abi.encodeWithSelector(
            PerfectPieV2.initialize.selector,
            owner
        );
        proxy = new ERC1967Proxy(address(implementation), initData);
        
        // Cast proxy to token interface
        token = PerfectPieV2(address(proxy));
    }
    
    function testInitialization() public view {
        assertEq(token.name(), "Perfect Pie");
        assertEq(token.symbol(), "PIE");
        assertEq(token.totalSupply(), MAX_SUPPLY);
        assertEq(token.balanceOf(address(token)), MAX_SUPPLY);
        assertEq(token.owner(), owner);
    }
    
    function testCannotInitializeTwice() public {
        vm.expectRevert();
        token.initialize(user1);
    }
    
    function testClaim() public {
        uint256 amount = 1000 * 10 ** 18;
        uint256 epoch = 1;
        
        // Create signature
        bytes32 messageHash = keccak256(abi.encodePacked(user1, amount, epoch));
        bytes32 ethSignedMessageHash = keccak256(
            abi.encodePacked("\x19Ethereum Signed Message:\n32", messageHash)
        );
        (uint8 v, bytes32 r, bytes32 s) = vm.sign(ownerPrivateKey, ethSignedMessageHash);
        bytes memory signature = abi.encodePacked(r, s, v);
        
        // Claim tokens
        vm.prank(user1);
        token.claim(user1, amount, epoch, signature);
        
        assertEq(token.balanceOf(user1), amount);
        assertEq(token.balanceOf(address(token)), MAX_SUPPLY - amount);
    }
    
    function testAdminBurn() public {
        // First give user1 some tokens
        uint256 amount = 1000 * 10 ** 18;
        uint256 epoch = 1;
        
        bytes32 messageHash = keccak256(abi.encodePacked(user1, amount, epoch));
        bytes32 ethSignedMessageHash = keccak256(
            abi.encodePacked("\x19Ethereum Signed Message:\n32", messageHash)
        );
        (uint8 v, bytes32 r, bytes32 s) = vm.sign(ownerPrivateKey, ethSignedMessageHash);
        bytes memory signature = abi.encodePacked(r, s, v);
        
        vm.prank(user1);
        token.claim(user1, amount, epoch, signature);
        
        uint256 balanceBefore = token.balanceOf(user1);
        assertEq(balanceBefore, amount);
        
        // Admin burns half of user1's tokens
        uint256 burnAmount = amount / 2;
        vm.prank(owner);
        token.adminBurn(user1, burnAmount);
        
        assertEq(token.balanceOf(user1), balanceBefore - burnAmount);
        assertEq(token.totalSupply(), MAX_SUPPLY - burnAmount);
    }
    
    function testAdminBurnEmitsEvent() public {
        // Give user1 some tokens first
        uint256 amount = 1000 * 10 ** 18;
        _giveTokensToUser(user1, amount);
        
        uint256 burnAmount = 500 * 10 ** 18;
        
        vm.expectEmit(true, false, true, true);
        emit PerfectPieV2.AdminBurn(user1, burnAmount, owner);
        
        vm.prank(owner);
        token.adminBurn(user1, burnAmount);
    }
    
    function testOnlyOwnerCanAdminBurn() public {
        uint256 amount = 1000 * 10 ** 18;
        _giveTokensToUser(user1, amount);
        
        vm.prank(user2);
        vm.expectRevert();
        token.adminBurn(user1, 100 * 10 ** 18);
    }
    
    function testCannotAdminBurnZeroAmount() public {
        _giveTokensToUser(user1, 1000 * 10 ** 18);
        
        vm.prank(owner);
        vm.expectRevert("Amount must be greater than 0");
        token.adminBurn(user1, 0);
    }
    
    function testCannotAdminBurnFromZeroAddress() public {
        vm.prank(owner);
        vm.expectRevert("Cannot burn from zero address");
        token.adminBurn(address(0), 100 * 10 ** 18);
    }
    
    function testCannotAdminBurnMoreThanBalance() public {
        uint256 amount = 1000 * 10 ** 18;
        _giveTokensToUser(user1, amount);
        
        vm.prank(owner);
        vm.expectRevert("Insufficient balance to burn");
        token.adminBurn(user1, amount + 1);
    }
    
    function testRegularBurnStillWorks() public {
        uint256 amount = 1000 * 10 ** 18;
        _giveTokensToUser(user1, amount);
        
        uint256 burnAmount = 100 * 10 ** 18;
        vm.prank(user1);
        token.burn(burnAmount);
        
        assertEq(token.balanceOf(user1), amount - burnAmount);
        assertEq(token.totalSupply(), MAX_SUPPLY - burnAmount);
    }
    
    function testUpgradeableByOwner() public {
        // Deploy new implementation
        PerfectPieV2 newImplementation = new PerfectPieV2();
        
        // Upgrade as owner
        vm.prank(owner);
        token.upgradeToAndCall(address(newImplementation), "");
        
        // Verify state is preserved
        assertEq(token.name(), "Perfect Pie");
        assertEq(token.symbol(), "PIE");
        assertEq(token.totalSupply(), MAX_SUPPLY);
        assertEq(token.owner(), owner);
    }
    
    function testOnlyOwnerCanUpgrade() public {
        PerfectPieV2 newImplementation = new PerfectPieV2();
        
        vm.prank(user1);
        vm.expectRevert();
        token.upgradeToAndCall(address(newImplementation), "");
    }
    
    // Helper function to give tokens to a user
    function _giveTokensToUser(address user, uint256 amount) internal {
        uint256 epoch = block.timestamp;
        bytes32 messageHash = keccak256(abi.encodePacked(user, amount, epoch));
        bytes32 ethSignedMessageHash = keccak256(
            abi.encodePacked("\x19Ethereum Signed Message:\n32", messageHash)
        );
        (uint8 v, bytes32 r, bytes32 s) = vm.sign(ownerPrivateKey, ethSignedMessageHash);
        bytes memory signature = abi.encodePacked(r, s, v);
        
        vm.prank(user);
        token.claim(user, amount, epoch, signature);
    }
}