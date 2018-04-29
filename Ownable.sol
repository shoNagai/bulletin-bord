pragma solidity ^0.4.18;

contract Ownable {
    // オーナー
    address public owner;

    // オーナーチェック
    modifier onlyOwner() {
        require(msg.sender == owner);
        _;
    }

    // コンストラクタ
    function Ownable() public {
        owner = msg.sender;
    }

    // オーナー変更
    function changeOwner(address _newOwner) public onlyOwner {
        owner = _newOwner;
    }
}