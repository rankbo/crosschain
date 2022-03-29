pragma solidity >=0.4.17 <0.9.0;
pragma experimental ABIEncoderV2;

library BurnEvent {
    event Burned (
        uint128 amount,
        address token
    );

    struct BurnEventData {
        // address unLocker;
        uint256 amount;
        address token;
        address recipient;
    }

    function parse(bytes memory data)
    internal
    pure
    returns (BurnEventData memory burnEvent)
    {
        (burnEvent.amount, burnEvent.token, burnEvent.recipient) = abi.decode(data, (uint256, address, address));
    }
}