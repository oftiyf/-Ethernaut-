// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;
contract Hack {
    constructor(MagicNum target) {
        address addr;
        bytes memory bytecode =hex"69
        target.setSolver(addr);
    }
    
}
contract MagicNum {
//有趣的是，题目中的SolverwhatIsTheMeaningOfLife()是42
//本题要求操作符小于10个，所以智能使用汇编
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