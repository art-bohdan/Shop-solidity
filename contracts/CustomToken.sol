//SPDX-License-Identifier: Unlicense
pragma solidity ^0.8.0;
import "./ERC20.sol";

contract CustomToken is ERC20 {
  constructor(
    string memory _name,
    string memory _symbol,
    uint256 _decimals,
    uint256 totalSupply,
    address initialOwner
  ) ERC20(_name, _symbol, _decimals, totalSupply, initialOwner) {}
}
