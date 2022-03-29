pragma solidity >=0.4.17 <0.9.0;
pragma experimental ABIEncoderV2;

library LockEvent {
    event Locked (
        address indexed fromToken,
        // address indexed toToken,
        // uint64  toChainId,
        address indexed sender,
        uint256 amount,
        string accountId
    );

    struct LockEventData {
        // address locker;
        address fromToken;
        // address toToken;
        // uint64  toChainId;
        address sender;
        uint256 amount;
        address recipient;
    }

    function parse(bytes memory data)
        internal
        pure
        returns (LockEventData memory lockEvent)
    {
        // (lockEvent.fromToken, lockEvent.toToken, lockEvent.toChainId, lockEvent.sender, lockEvent.amount, lockEvent.recipient) = abi.decode(data, (address, address, uint64, address, uint256, address));
        (lockEvent.fromToken, lockEvent.sender, lockEvent.amount, lockEvent.recipient) = abi.decode(data, (address, address, uint256, address));
    }
}