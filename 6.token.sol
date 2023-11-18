// SPDX-License-Identifier: MIT
pragma solidity ^0.6.0;//这题的思路在于这里使用的是0.6，不具备safemath安全数学库，可以使用整数溢出
contract Token {

  mapping(address => uint) balances;
  uint public totalSupply;

  constructor(uint _initialSupply) public {
    balances[msg.sender] = totalSupply = _initialSupply;
  }

  function transfer(address _to, uint _value) public returns (bool) {
    require(balances[msg.sender] - _value >= 0);//这个地方就是被攻击点，如果msg.sender的余额为0，就会向下溢出
    balances[msg.sender] -= _value;
    balances[_to] += _value;
    return true;
  }

  function balanceOf(address _owner) public view returns (uint balance) {
    return balances[_owner];
  }
}
