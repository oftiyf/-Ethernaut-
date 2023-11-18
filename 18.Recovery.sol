// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;
contract Dev {
    function recover(address sender) external pure returns (address){
        /*nonce0= address(uint160(uint256(
            keccak256(abi.encodePacked(
                bytes1(0xd6), bytes1(0x94), _origin, bytes1(0x80)
                ))
                )));
        nonce1= address(uint160(uint256(
            keccak256(abi.encodePacked(
                bytes1(0xd6), bytes1(0x94), _origin, bytes1(0x01)
                ))
                )));//这是使用账户来创造合约的计算公式，随机的,我第一次使用nonce1
                输入目标合约的地址，得到的合约地址
                但是如果在etherscan查找这个地址（注意要在etherscan切换一下测试网络），当中并没有找到题目中所说的0.01个eth，说明错了
                更换另一个nonce即可*/
        address addr = address(uint160(uint256(
            keccak256(abi.encodePacked(
                bytes1(0xd6), bytes1(0x94), sender, bytes1(0x01)
                ))
                )));//这个地方把——origin改为了sender，通过验证的知这边是正确的
                return addr;//通过以上的行为可以得到我们所需要的合约地址，然后利用这个来部署下面的SimpleToken合约即可
                /*address addr= address(uint160(uint256(
            keccak256(abi.encodePacked(
                bytes1(0xd6), bytes1(0x94), sender, bytes1(0x80)
                ))//这个地方把——origin改为了sender
                )));
                return addr;*/
                
    }
    
}
contract Recovery {

  //generate tokens
  function generateToken(string memory _name, uint256 _initialSupply) public {
    new SimpleToken(_name, msg.sender, _initialSupply);
  
  }
}

contract SimpleToken {

  string public name;
  mapping (address => uint) public balances;

  // constructor
  constructor(string memory _name, address _creator, uint256 _initialSupply) {
    name = _name;
    balances[_creator] = _initialSupply;
  }

  // collect ether in return for tokens
  receive() external payable {
    balances[msg.sender] = msg.value * 10;
  }

  // allow transfers of tokens
  function transfer(address _to, uint _amount) public { 
    require(balances[msg.sender] >= _amount);
    balances[msg.sender] = balances[msg.sender] - _amount;
    balances[_to] = _amount;
  }

  // clean up after ourselves
  function destroy(address payable _to) public {
    selfdestruct(_to);
  }
}
