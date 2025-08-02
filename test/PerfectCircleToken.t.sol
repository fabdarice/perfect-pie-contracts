// SPDX-License-Identifier: MIT
pragma solidity ^0.8.13;

import "forge-std/Test.sol";
import "../src/PerfectPieToken.sol";

contract PerfectPieTokenTest is Test {
    PerfectPie public token;
    address public owner;
    address public user1;
    address public user2;
    uint256 public ownerPrivateKey;
    uint256 public user1PrivateKey;

    function setUp() public {
        ownerPrivateKey = 0x1234;
        user1PrivateKey = 0x5678;
        
        owner = vm.addr(ownerPrivateKey);
        user1 = vm.addr(user1PrivateKey);
        user2 = makeAddr("user2");

        vm.prank(owner);
        token = new PerfectPie(owner);
    }

    function testDeployment() public {
        assertEq(token.name(), "Perfect Pie");
        assertEq(token.symbol(), "PIE");
        assertEq(token.decimals(), 18);
        assertEq(token.totalSupply(), 10e9 * 10**18);
        assertEq(token.balanceOf(address(token)), 10e9 * 10**18);
        assertEq(token.owner(), owner);
    }

    function testClaimWithValidSignature() public {
        uint256 amount = 1000 * 10**18;
        uint256 epoch = 1;
        
        bytes32 messageHash = keccak256(abi.encodePacked(user1, amount, epoch));
        bytes32 ethSignedMessageHash = keccak256(abi.encodePacked("\x19Ethereum Signed Message:\n32", messageHash));
        
        (uint8 v, bytes32 r, bytes32 s) = vm.sign(ownerPrivateKey, ethSignedMessageHash);
        bytes memory signature = abi.encodePacked(r, s, v);

        uint256 initialBalance = token.balanceOf(user1);
        uint256 initialContractBalance = token.getContractBalance();

        vm.expectEmit(true, true, true, true);
        emit PerfectPie.Claimed(user1, amount, epoch, keccak256(signature));

        token.claim(user1, amount, epoch, signature);

        assertEq(token.balanceOf(user1), initialBalance + amount);
        assertEq(token.getContractBalance(), initialContractBalance - amount);
        assertTrue(token.usedSignatures(keccak256(signature)));
    }

    function testClaimRejectsReusedSignature() public {
        uint256 amount = 1000 * 10**18;
        uint256 epoch = 1;
        
        bytes32 messageHash = keccak256(abi.encodePacked(user1, amount, epoch));
        bytes32 ethSignedMessageHash = keccak256(abi.encodePacked("\x19Ethereum Signed Message:\n32", messageHash));
        
        (uint8 v, bytes32 r, bytes32 s) = vm.sign(ownerPrivateKey, ethSignedMessageHash);
        bytes memory signature = abi.encodePacked(r, s, v);

        token.claim(user1, amount, epoch, signature);

        vm.expectRevert("Signature already used");
        token.claim(user1, amount, epoch, signature);
    }

    function testClaimRejectsInvalidSignature() public {
        uint256 amount = 1000 * 10**18;
        uint256 epoch = 1;
        
        bytes32 messageHash = keccak256(abi.encodePacked(user1, amount, epoch));
        bytes32 ethSignedMessageHash = keccak256(abi.encodePacked("\x19Ethereum Signed Message:\n32", messageHash));
        
        (uint8 v, bytes32 r, bytes32 s) = vm.sign(user1PrivateKey, ethSignedMessageHash);
        bytes memory signature = abi.encodePacked(r, s, v);

        vm.expectRevert("Invalid signature");
        token.claim(user1, amount, epoch, signature);
    }

    function testClaimRejectsZeroAddress() public {
        uint256 amount = 1000 * 10**18;
        uint256 epoch = 1;
        
        bytes32 messageHash = keccak256(abi.encodePacked(address(0), amount, epoch));
        bytes32 ethSignedMessageHash = keccak256(abi.encodePacked("\x19Ethereum Signed Message:\n32", messageHash));
        
        (uint8 v, bytes32 r, bytes32 s) = vm.sign(ownerPrivateKey, ethSignedMessageHash);
        bytes memory signature = abi.encodePacked(r, s, v);

        vm.expectRevert("Invalid receiver address");
        token.claim(address(0), amount, epoch, signature);
    }

    function testClaimRejectsZeroAmount() public {
        uint256 amount = 0;
        uint256 epoch = 1;
        
        bytes32 messageHash = keccak256(abi.encodePacked(user1, amount, epoch));
        bytes32 ethSignedMessageHash = keccak256(abi.encodePacked("\x19Ethereum Signed Message:\n32", messageHash));
        
        (uint8 v, bytes32 r, bytes32 s) = vm.sign(ownerPrivateKey, ethSignedMessageHash);
        bytes memory signature = abi.encodePacked(r, s, v);

        vm.expectRevert("Amount must be greater than 0");
        token.claim(user1, amount, epoch, signature);
    }

    function testClaimRejectsInsufficientContractBalance() public {
        uint256 amount = token.getContractBalance() + 1;
        uint256 epoch = 1;
        
        bytes32 messageHash = keccak256(abi.encodePacked(user1, amount, epoch));
        bytes32 ethSignedMessageHash = keccak256(abi.encodePacked("\x19Ethereum Signed Message:\n32", messageHash));
        
        (uint8 v, bytes32 r, bytes32 s) = vm.sign(ownerPrivateKey, ethSignedMessageHash);
        bytes memory signature = abi.encodePacked(r, s, v);

        vm.expectRevert("Insufficient contract balance");
        token.claim(user1, amount, epoch, signature);
    }

    function testBurnFunctionality() public {
        uint256 amount = 1000 * 10**18;
        uint256 epoch = 1;
        
        bytes32 messageHash = keccak256(abi.encodePacked(user1, amount, epoch));
        bytes32 ethSignedMessageHash = keccak256(abi.encodePacked("\x19Ethereum Signed Message:\n32", messageHash));
        
        (uint8 v, bytes32 r, bytes32 s) = vm.sign(ownerPrivateKey, ethSignedMessageHash);
        bytes memory signature = abi.encodePacked(r, s, v);

        token.claim(user1, amount, epoch, signature);

        uint256 burnAmount = 500 * 10**18;
        uint256 initialTotalSupply = token.totalSupply();
        uint256 initialUserBalance = token.balanceOf(user1);

        vm.prank(user1);
        token.burn(burnAmount);

        assertEq(token.totalSupply(), initialTotalSupply - burnAmount);
        assertEq(token.balanceOf(user1), initialUserBalance - burnAmount);
    }


    function testMultipleClaimsWithDifferentEpochs() public {
        uint256 amount = 1000 * 10**18;
        
        for (uint256 epoch = 1; epoch <= 3; epoch++) {
            bytes32 messageHash = keccak256(abi.encodePacked(user1, amount, epoch));
            bytes32 ethSignedMessageHash = keccak256(abi.encodePacked("\x19Ethereum Signed Message:\n32", messageHash));
            
            (uint8 v, bytes32 r, bytes32 s) = vm.sign(ownerPrivateKey, ethSignedMessageHash);
            bytes memory signature = abi.encodePacked(r, s, v);

            token.claim(user1, amount, epoch, signature);
        }

        assertEq(token.balanceOf(user1), amount * 3);
    }

    function testGetContractBalance() public {
        uint256 expectedBalance = 10e9 * 10**18;
        assertEq(token.getContractBalance(), expectedBalance);
        
        uint256 amount = 1000 * 10**18;
        uint256 epoch = 1;
        
        bytes32 messageHash = keccak256(abi.encodePacked(user1, amount, epoch));
        bytes32 ethSignedMessageHash = keccak256(abi.encodePacked("\x19Ethereum Signed Message:\n32", messageHash));
        
        (uint8 v, bytes32 r, bytes32 s) = vm.sign(ownerPrivateKey, ethSignedMessageHash);
        bytes memory signature = abi.encodePacked(r, s, v);

        token.claim(user1, amount, epoch, signature);
        
        assertEq(token.getContractBalance(), expectedBalance - amount);
    }
}