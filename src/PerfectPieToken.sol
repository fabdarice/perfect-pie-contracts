// SPDX-License-Identifier: MIT
pragma solidity ^0.8.13;

import "@openzeppelin/contracts/token/ERC20/ERC20.sol";
import "@openzeppelin/contracts/token/ERC20/extensions/ERC20Burnable.sol";
import "@openzeppelin/contracts/utils/cryptography/ECDSA.sol";
import "@openzeppelin/contracts/utils/cryptography/MessageHashUtils.sol";
import "@openzeppelin/contracts/access/Ownable.sol";

contract PerfectPie is ERC20, ERC20Burnable, Ownable {
    using ECDSA for bytes32;
    using MessageHashUtils for bytes32;

    uint256 public constant MAX_SUPPLY = 10e9 * 10 ** 18; // 10 billion tokens

    mapping(bytes32 => bool) public usedSignatures;

    event Claimed(
        address indexed receiver,
        uint256 amount,
        uint256 epoch,
        bytes32 signatureHash
    );

    constructor(
        address initialOwner
    ) ERC20("Perfect Pie", "PIE") Ownable(initialOwner) {
        _mint(address(this), MAX_SUPPLY);
    }

    function claim(
        address receiver,
        uint256 amount,
        uint256 epoch,
        bytes memory signature
    ) external {
        require(receiver != address(0), "Invalid receiver address");
        require(amount > 0, "Amount must be greater than 0");
        require(
            balanceOf(address(this)) >= amount,
            "Insufficient contract balance"
        );

        bytes32 messageHash = keccak256(
            abi.encodePacked(receiver, amount, epoch)
        );
        bytes32 ethSignedMessageHash = messageHash.toEthSignedMessageHash();

        bytes32 signatureHash = keccak256(signature);
        require(!usedSignatures[signatureHash], "Signature already used");

        address signer = ethSignedMessageHash.recover(signature);
        require(signer == owner(), "Invalid signature");

        usedSignatures[signatureHash] = true;

        _transfer(address(this), receiver, amount);

        emit Claimed(receiver, amount, epoch, signatureHash);
    }

    function getContractBalance() external view returns (uint256) {
        return balanceOf(address(this));
    }
}
