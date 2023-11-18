// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;
//这题玩了一个梗，要求写一个合约的返回值为42--what is the meaning of life
contract Hack{//虽然不完全懂汇编，但是这个地方等于创建了一个合约，使得它的操作码与所给的一致
//而这个操作码意思就是返回一个42
//然后再把这个地址传给指定合约就行
    constructor(MagicNum target) {
        bytes memory bytecode=hex"69602a60005260206000f3600052600a6016f3";
        address addr;
        assembly {
             addr:=create(0,add(bytecode,0x20),0x13)
             //这个地方的用法是create(value,offset,size)，这个采用的是十六进制，所以bytecode内代码/2再十六进制才是正确的13
        }
        require(addr!=address(0));//确保不等于0地址，也就是初始化成功
        target.setSolver(addr);
    }
}
contract MagicNum {

  address public solver;

  constructor() {}

  function setSolver(address _solver) public {
    solver = _solver;
  }

  /*
    ____________/\\\_______/\\\\\\\\\_____        
     __________/\\\\\_____/\\\///////\\\___       
      ________/\\\/\\\____\///______\//\\\__      
       ______/\\\/\/\\\______________/\\\/___     
        ____/\\\/__\/\\\___________/\\\//_____    
         __/\\\\\\\\\\\\\\\\_____/\\\//________   
          _\///////////\\\//____/\\\/___________  
           ___________\/\\\_____/\\\\\\\\\\\\\\\_ 
            ___________\///_____\///////////////__
  */
}
