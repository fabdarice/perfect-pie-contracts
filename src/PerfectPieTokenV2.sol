// SPDX-License-Identifier: MIT
pragma solidity ^0.8.13;

import "@openzeppelin/contracts-upgradeable/token/ERC20/ERC20Upgradeable.sol";
import "@openzeppelin/contracts-upgradeable/token/ERC20/extensions/ERC20BurnableUpgradeable.sol";
import "@openzeppelin/contracts-upgradeable/access/OwnableUpgradeable.sol";
import "@openzeppelin/contracts-upgradeable/proxy/utils/Initializable.sol";
import "@openzeppelin/contracts-upgradeable/proxy/utils/UUPSUpgradeable.sol";
import "@openzeppelin/contracts/utils/cryptography/ECDSA.sol";
import "@openzeppelin/contracts/utils/cryptography/MessageHashUtils.sol";

contract PerfectPieV2 is
    Initializable,
    ERC20Upgradeable,
    ERC20BurnableUpgradeable,
    OwnableUpgradeable,
    UUPSUpgradeable
{
    using ECDSA for bytes32;
    using MessageHashUtils for bytes32;

    uint256 public constant MAX_SUPPLY = 10e9 * 10 ** 18; // 10 billion tokens

    mapping(bytes32 => bool) public usedSignatures;

    event Claimed(address indexed receiver, uint256 amount, uint256 epoch, bytes32 signatureHash);

    event AdminBurn(address indexed from, uint256 amount, address indexed admin);

    /// @custom:oz-upgrades-unsafe-allow constructor
    constructor() {
        _disableInitializers();
    }

    function initialize(address initialOwner) public initializer {
        __ERC20_init("Perfect Pie", "PIE");
        __ERC20Burnable_init();
        __Ownable_init(initialOwner);
        __UUPSUpgradeable_init();

        _mint(address(this), MAX_SUPPLY);
    }

    function claim(address receiver, uint256 amount, uint256 epoch, bytes memory signature) external {
        require(receiver != address(0), "Invalid receiver address");
        require(amount > 0, "Amount must be greater than 0");
        require(balanceOf(address(this)) >= amount, "Insufficient contract balance");

        bytes32 messageHash = keccak256(abi.encodePacked(receiver, amount, epoch));
        bytes32 ethSignedMessageHash = messageHash.toEthSignedMessageHash();

        bytes32 signatureHash = keccak256(signature);
        require(!usedSignatures[signatureHash], "Signature already used");

        address signer = ethSignedMessageHash.recover(signature);
        require(signer == owner(), "Invalid signature");

        usedSignatures[signatureHash] = true;

        _transfer(address(this), receiver, amount);

        emit Claimed(receiver, amount, epoch, signatureHash);
    }

    /**
     * @dev Admin function to burn tokens from any account
     * @param from The address to burn tokens from
     * @param amount The amount of tokens to burn
     */
    function adminBurn(address from, uint256 amount) external onlyOwner {
        require(from != address(0), "Cannot burn from zero address");
        require(amount > 0, "Amount must be greater than 0");
        require(balanceOf(from) >= amount, "Insufficient balance to burn");

        _burn(from, amount);

        emit AdminBurn(from, amount, msg.sender);
    }

    function getContractBalance() external view returns (uint256) {
        return balanceOf(address(this));
    }

    /**
     * @dev Required override for UUPS proxy pattern
     * Only owner can authorize upgrades
     */
    function _authorizeUpgrade(address newImplementation) internal override onlyOwner {}
}
