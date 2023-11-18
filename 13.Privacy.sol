// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

contract Privacy {
  //这章会讲种以太坊的存储方式，每一个slot当中只能存32字节
  //如果要存的加上已经有的超过32字节（256位），那就存在下一slot
  bool public locked = true;//slot 0
  uint256 public ID = block.timestamp;//slot 1
  uint8 private flattening = 10;//slot 2
  uint8 private denomination = 255;//slot 2
  uint16 private awkwardness = uint16(block.timestamp);//slot 2
  bytes32[3] private data;//由于这个地方是数组，很明显存不下
  //所以分别存在slot345
  constructor(bytes32[3] memory _data) {
    data = _data;
  }
  
  function unlock(bytes16 _key) public {
    require(_key == bytes16(data[2]));//这个指的是这个合约的slot2中前16字节的数据
    locked = false;
  }

  /*
    contract.address
    一串地址
    addr = "0x0296F613a4c15C5c4D41cdbFf7973a8cA1687823"
    await web3.eth.getStorageAt(addr,5)//5指的就是private的东西
    得到一串码，（由于slot2均为private）
    data ="0x37ad355a501dc3fecb3ce8d7b7b6009e6868f0e6b6471ffcf6a8eeff64de0574"
    data.slice(0,2+2*16)//由于这里2个字符代表一个字节，而由于要获取前16个，前面还有一0x
    最终的得到要的秘钥
    0x37ad355a501dc3fecb3ce8d7b7b6009e
  */
}
