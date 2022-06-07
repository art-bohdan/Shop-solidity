//SPDX-License-Identifier: Unlicense
pragma solidity ^0.8.0;
import "./IERC20.sol";
import "./CustomToken.sol";

contract Shop {
  IERC20 public token;
  address payable public owner;
  event Bought(uint256 _amount, address indexed _buyer);
  event Sold(uint256 _amount, address indexed _seller);

  constructor(string memory _name, string memory _symbol,uint256 _decimals, uint256 _totalSupply) {
    token = new CustomToken(_name, _symbol, _decimals, _totalSupply, address(this));
    owner = payable(msg.sender);
  }

  modifier onlyOwner() {
    require(msg.sender == owner, "not an owner!");
    _;
  }

  function sell(uint256 _amountToSell) external {
    require(_amountToSell > 0 && token.balanceOf(msg.sender) >= _amountToSell, "incorrect amount!");

    uint256 allowance = token.allowance(msg.sender, address(this));
    require(allowance >= _amountToSell, "check allowance!");

    token.transferFrom(msg.sender, address(this), _amountToSell);

    payable(msg.sender).transfer(_amountToSell);

    emit Sold(_amountToSell, msg.sender);
  }

  receive() external payable {
    uint256 tokensToBuy = msg.value; // 1 wei = 1 token
    require(tokensToBuy > 0, "not enough funds!");

    require(tokenBalance() >= tokensToBuy, "not enough tokens!");

    token.transfer(msg.sender, uint256(tokensToBuy));
    emit Bought(tokensToBuy, msg.sender);
  }

  function tokenBalance() public view returns (uint256) {
    return token.balanceOf(address(this));
  }

  function withdraw(uint256 amount) external onlyOwner {
    require(amount < token.balanceOf(msg.sender));
    address payable to = payable(msg.sender);
    to.transfer(tokenBalance());
  }
}
