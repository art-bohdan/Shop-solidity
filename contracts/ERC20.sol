//SPDX-License-Identifier: Unlicense
pragma solidity ^0.8.0;
import "./IERC20.sol";

contract ERC20 is IERC20 {
  //Variables
  uint256 public _totalSupply;
  mapping(address => uint256) _balanceOf;
  mapping(address => mapping(address => uint256)) _allowance;

  string public _name;
  string public _symbol;
  uint256 immutable public _decimals;

  constructor(
    string memory name_,
    string memory symbol_,
    uint256 dec,
    uint256 totalSupply_,
    address initialOwner
  ) {
    _name = name_;
    _symbol = symbol_;
    _decimals = dec;
    _mint(totalSupply_, initialOwner);
  }

  //Function
  function name() public view override returns (string memory) {
    return _name;
  }

  // returns Symbol token
  function symbol() public view override returns (string memory) {
    return _symbol;
  }

  // returns decimals
  function decimals() public view override returns (uint256) {
    return _decimals;
  }

  // returns balances from account address
  function balanceOf(address account) public view override returns (uint256) {
    return _balanceOf[account];
  }

  function increaseAllowance(address spender, uint64 addedValue) external returns (bool) {
    require(spender != address(0), "ERC20: spender should be not a zero address");
    _allowance[msg.sender][spender] += addedValue;
    emit Approval(msg.sender, spender, addedValue);
    return true;
  }

  function decreaseAllowance(address spender, uint64 addedValue) public returns (bool) {
    require(spender != address(0), "ERC20: spender should be not a zero address");
    _allowance[msg.sender][spender] -= addedValue;
    emit Approval(msg.sender, spender, addedValue);
    return true;
  }

  function totalSupply() public view override returns (uint256) {
    return _totalSupply;
  }

  function allowance(address _owner, address spender) external view override returns (uint256) {
    return _allowance[_owner][spender];
  }

  function transfer(address to, uint256 amount) external override returns (bool) {
    require(_balanceOf[msg.sender] >= amount, "ERC20: transfer amount exceeds balance");
    _balanceOf[msg.sender] -= amount;
    _balanceOf[to] += amount;
    emit Transfer(msg.sender, to, amount);
    return true;
  }

  function approve(address spender, uint256 amount) external override returns (bool) {
    require(spender != address(0), "ERC20: approve to the zero address");
    _allowance[msg.sender][spender] = amount;
    emit Approval(msg.sender, spender, amount);
    return true;
  }

    // function _beforeTokenTransfer(address from, address to, uint256 amount) internal view {
    //     require(_balanceOf[from] != 0, "ERC20: not enough funds on account");
    // }

    // function _afterTokenTransfer(address from, address to, uint256 amount) internal view {
    // }

  function transferFrom(
    address from,
    address to,
    uint256 amount
  ) external override returns (bool) {
    require(_allowance[from][msg.sender] >= amount, "ERC20: not enough allowance funds on account");
    _allowance[from][msg.sender] -= amount;
    _balanceOf[from] -= amount;
    _balanceOf[to] += amount;
    emit Transfer(from, msg.sender, amount);
    return true;
  }

  function burnFrom(address from, uint256 amount) external returns (bool) {
    require(_balanceOf[from] >= amount, "ERC20: not enough funds on account");
    require(_allowance[from][msg.sender] >= amount, "ERC20: not enough allowance funds");
    _allowance[from][msg.sender] -= amount;
    _balanceOf[from] -= amount;
    _totalSupply -= amount;
    emit Transfer(from, address(0), amount);
    return true;
  }

  function _mint(uint256 amount, address _owner) internal {
    _balanceOf[_owner] += amount;
    _totalSupply += amount;
    emit Transfer(address(0), _owner, amount);
  }

  function _burn(uint256 amount) external {
    require(msg.sender != address(0), "ERC20: burn to the zero address");
    require(_balanceOf[msg.sender] >= amount, "ERC20 not enough funds");
    _balanceOf[msg.sender] -= amount;
    _totalSupply -= amount;
    emit Transfer(msg.sender, address(0), amount);
  }
}
