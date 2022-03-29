pragma solidity >=0.4.17 <0.9.0;

library UnLockEvent {
    event Unlocked (
        uint128 amount,
        address recipient
    );
}