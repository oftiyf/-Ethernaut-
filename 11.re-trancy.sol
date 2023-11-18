pragma solidity ^0.6.12;
import "safemath.sol";
contract Reentrance {//这一题就是典型的重入攻击
  
  using SafeMath for uint256;
  mapping(address => uint) public balances;

  function donate(address _to) public payable {
    balances[_to] = balances[_to].add(msg.value);
  }

  function balanceOf(address _who) public view returns (uint balance) {
    return balances[_who];
  }

  function withdraw(uint _amount) public {
    if(balances[msg.sender] >= _amount) {
      (bool result,) = msg.sender.call{value:_amount}("");
      if(result) {//这个if语句并没有写全，题目不涉及
        _amount;
      }//思路：只要一直不到下面这个命令就可以一直取款
      //解法：攻击合约调用这个函数，并且定义fallback函数来调用反复调用
      balances[msg.sender] -= _amount;
    }
  }

  receive() external payable {}
}