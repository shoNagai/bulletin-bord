pragma solidity ^0.4.18;

import "./Ownable.sol";

// 緊急停止用コントラクト
contract CircuitBreaker is Ownable {
    
    bool public stopped;    // 停止制御

    // 停止チェック
    modifier isStopped() {
        // 停止されてない場合
        require(!stopped);
        _;
    }
    
    // 停止フラグの制御
    function toggleCircuit(bool _stopped) public onlyOwner {
        stopped = _stopped;
    }
}