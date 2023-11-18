// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

contract Vault {
  bool public locked;
  bytes32 private password;//由于这里是private，所以不能直接访问它
//但是由于这些都是开源的所以可以再web3内置的东西查看
  constructor(bytes32 _password) {//这里虽然也有_password，但是和下面的不一致，只是同名而已
    locked = true;
    password = _password;//这里初始化了password的值
  }

  function unlock(bytes32 _password) public {
    if (password == _password) {
      locked = false;
    }
  }
}//解题思路：f12之后在控制台内输入 await web3.eth.getStorageAt(contract.address,1)
//在这个合约下可以看到，  bool public locked是第一个存放的状态变量存放在了0的位置上
//而bytes32 private password作为第二个状态变量存放在了1的位置上
//由此可得到密码为
//0x412076657279207374726f6e67207365637265742070617373776f7264203a29