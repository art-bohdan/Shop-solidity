//SPDX-License-Identifier: Unlicense
pragma solidity ^0.8.0;
import "./ERC20.sol";

contract CustomToken is ERC20 {
  constructor(uint256 totalSupply, address shop) ERC20("CustomToken", "CT", 18, totalSupply, shop) {}
}
