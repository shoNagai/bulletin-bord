pragma solidity ^0.4.18;

import "./Ownable.sol";

// 破棄用コントラクト
contract Mortal is Ownable {
    // コントラクトの破棄して、etherをownerへ送る
    function kill() public onlyOwner {
        selfdestruct(owner);
    }
}