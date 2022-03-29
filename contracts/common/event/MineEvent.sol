pragma solidity >=0.4.17 <0.9.0;

library MineEvent {
    event Mined (
        address indexed token,
        address indexed sender,
        uint256 amount,
        string accountId
    );
}